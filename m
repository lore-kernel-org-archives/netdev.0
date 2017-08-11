From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Performance comparision / qdisc / no qdisc / queueing linux
 kernel 4.12
Date: Fri, 11 Aug 2017 16:16:06 -0700
Message-ID: <20170811161606.561b3fbb@xeon-e3>
References: <a59c1fdf-9c32-50f6-eb45-040e4ce30cff@itcare.pl>
        <fa7bc3ce-5dc7-e236-ec35-0afe3fc830bc@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33212 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdHKXQO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 19:16:14 -0400
Received: by mail-pg0-f52.google.com with SMTP id u5so20818314pgn.0
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 16:16:13 -0700 (PDT)
In-Reply-To: <fa7bc3ce-5dc7-e236-ec35-0afe3fc830bc@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any of the current qdisc that do rate control are single threaded.
Since bandwidth is a shared resource, the qdisc has to acquire a lock
and update cache shared data structures.

Don't expect HTB or HFSC to be free.

> 
> 4.13-rc3 have kernel panic when deleting qdisc - will try to get panic trace

Please do.
