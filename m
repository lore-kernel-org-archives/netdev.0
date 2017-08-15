From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 05/51] iplink_can: Prevent overstepping array
 bounds
Date: Tue, 15 Aug 2017 08:10:49 -0700
Message-ID: <20170815081049.10ef8e06@xeon-e3>
References: <20170812120510.28750-1-phil@nwl.cc>
        <20170812120510.28750-6-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36863 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750936AbdHOPKv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:10:51 -0400
Received: by mail-pg0-f45.google.com with SMTP id i12so7275010pgr.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 08:10:51 -0700 (PDT)
In-Reply-To: <20170812120510.28750-6-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Aug 2017 14:04:24 +0200
Phil Sutter <phil@nwl.cc> wrote:

> can_state_names array contains at most CAN_STATE_MAX fields, so allowing
> an index to it to be equal to that number is wrong. While here, also
> make sure the array is indeed that big so nothing bad happens if
> CAN_STATE_MAX ever increases.

No more speculative bug fixes.
