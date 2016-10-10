From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] tc: f_u32: Fill in 'linkid' provided by user
Date: Sun, 9 Oct 2016 18:58:20 -0700
Message-ID: <20161009185820.2c23efef@xeon-e3>
References: <20160928183016.23280.39364.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com
To: Sushma Sitaram <sushma.sitaram@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33747 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751488AbcJJB6F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 21:58:05 -0400
Received: by mail-pa0-f51.google.com with SMTP id vu5so7977336pab.0
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 18:58:05 -0700 (PDT)
In-Reply-To: <20160928183016.23280.39364.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Sep 2016 11:30:16 -0700
Sushma Sitaram <sushma.sitaram@intel.com> wrote:

> Currently, 'linkid' input by the user is parsed but 'handle' is appended to the netlink message.
> 
> # tc filter add dev enp1s0f1 protocol ip parent ffff: prio 99 u32 ht 800: \
> 	order 1 link 1: offset at 0 mask 0f00 shift 6 plus 0 eat match ip \
> 	protocol 6 ff
> 
> resulted in:
> filter protocol ip pref 99 u32 fh 800::1 order 1 key ht 800 bkt 0
>   match 00060000/00ff0000 at 8
>     offset 0f00>>6 at 0  eat
> 
> This patch results in:
> filter protocol ip pref 99 u32 fh 800::1 order 1 key ht 800 bkt 0 link 1:
>   match 00060000/00ff0000 at 8
>     offset 0f00>>6 at 0  eat
> 
> 
> Signed-off-by Sushma Sitaram: Sushma Sitaram <sushma.sitaram@intel.com>

Applied (for 4.8).
