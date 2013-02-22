From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fec: Ensure that initialization is done prior to request_irq()
Date: Fri, 22 Feb 2013 13:22:55 -0300
Message-ID: <CAOMZO5AcSC5vwXsAcRZBS70WF6Zbfp4Q09iStZZEFMoWvNqzSg@mail.gmail.com>
References: <1361474510-14286-1-git-send-email-fabio.estevam@freescale.com>
	<20130221.152724.6508078801736235.davem@davemloft.net>
	<CAOMZO5ArHJy=KN8R5F0cOhDN=MnxRTmBUOgDsn8zutrTNw=igg@mail.gmail.com>
	<20130221.153812.2039434956437238374.davem@davemloft.net>
	<loom.20130222T020618-678@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:63543 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757424Ab3BVQW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 11:22:58 -0500
Received: by mail-wg0-f41.google.com with SMTP id ds1so1598291wgb.2
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 08:22:56 -0800 (PST)
In-Reply-To: <loom.20130222T020618-678@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 10:13 PM, Jim Baxter <jim_baxter@mentor.com> wrote:

> There is a divide by zero error.
>
> If I enable these 3 kernel hacking options;
> CONFIG_DEBUG_SPINLOCK:   -- Spinlock and rw-lock debugging: basic checks
> CONFIG_DEBUG_LOCK_ALLOC: -- Lock debugging: detect incorrect freeing of live
> locks
> CONFIG_PROVE_LOCKING:    -- Lock debugging: prove locking correctness

Thanks for reporting this issue, Jim.

I was testing under mx53, which did not show this problem.

I have a fix for this and I have tested it on both mx6q and mx53. Will
submit it shortly.
