From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 01/51] devlink: Check return code of
 strslashrsplit()
Date: Tue, 15 Aug 2017 08:09:54 -0700
Message-ID: <20170815080954.3c85ba55@xeon-e3>
References: <20170812120510.28750-1-phil@nwl.cc>
        <20170812120510.28750-2-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35264 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdHOPKC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:10:02 -0400
Received: by mail-pg0-f53.google.com with SMTP id v189so7263612pgd.2
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 08:10:01 -0700 (PDT)
In-Reply-To: <20170812120510.28750-2-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Aug 2017 14:04:20 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This function shouldn't fail because all callers of
> __dl_argv_handle_port() make sure the passed string contains enough
> slashes already, but better make sure if this changes in future the
> function won't access uninitialized data.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Ok, but please don't go too far down the dead end of addressing all possible
"if code changes in the future this would be a bug". Keep to finding
and fixing the real bugs that exist today.
