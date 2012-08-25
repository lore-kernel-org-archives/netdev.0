From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH] af_unix: fix unix_nr_socks check in unix_create1()
Date: Sat, 25 Aug 2012 12:17:40 -0400
Message-ID: <65347D45-9062-4F03-AB13-24321FF5B64A@gmail.com>
References: <1345874753-7214-1-git-send-email-xi.wang@gmail.com> <1345876989.19483.83.camel@edumazet-glaptop>
Mime-Version: 1.0 (Mac OS X Mail 6.0 \(1486\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38382 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab2HYQRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 12:17:45 -0400
Received: by ialo24 with SMTP id o24so5403807ial.19
        for <netdev@vger.kernel.org>; Sat, 25 Aug 2012 09:17:44 -0700 (PDT)
In-Reply-To: <1345876989.19483.83.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Aug 25, 2012, at 2:43 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> I dont think this patch is right.
> 
> atomic_long_inc_return() is expensive, more than atomic_long_inc()
> 
> And setting a 2^63 limit for max number of files is plain wrong,
> as there is no way a kernel can allocate 2^63 files structures.
> 
> (same apply on 32bit arches, but for 2^31)
> 
> If you feel you must warn a sysadmin of stupid settings, add sane
> boundaries in kernel/sysctl.c, and send your patch to lkml instead.

Yeah, I agree it's better to limit max_files in sysctl.  I will send
another patch instead.  Thanks.

- xi
