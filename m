From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH] net: fec: Ensure that initialization is done prior to request_irq()
Date: Fri, 22 Feb 2013 09:44:43 +0800
Message-ID: <CAHrpEqT=4ZVQry+Q7aGmnvBK2Px3EhjnDPuPmothB_rHzqOwiA@mail.gmail.com>
References: <1361474510-14286-1-git-send-email-fabio.estevam@freescale.com>
	<20130221.152724.6508078801736235.davem@davemloft.net>
	<CAOMZO5ArHJy=KN8R5F0cOhDN=MnxRTmBUOgDsn8zutrTNw=igg@mail.gmail.com>
	<20130221.153812.2039434956437238374.davem@davemloft.net>
	<loom.20130222T020618-678@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>,
	Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:60542 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777Ab3BVBop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 20:44:45 -0500
Received: by mail-we0-f180.google.com with SMTP id k14so121134wer.25
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 17:44:44 -0800 (PST)
In-Reply-To: <loom.20130222T020618-678@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug should be fixed in

http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commit;h=365cc174648cd7e9b11e522c3d5b07ccf3c60d99

2013/2/22 Jim Baxter <jim_baxter@mentor.com>:
> here is a divide by zero error.
>
> If I enable these 3 kernel hacking options;
> CONFIG_DEBUG_SPINLOCK:   -- Spinlock and rw-lock debugging: basic checks
> CONFIG_DEBUG_LOCK_ALLOC: -- Lock debugging: detect incorrect freeing of live
> locks
> CONFIG_PROVE_LOCKING:    -- Lock debugging: prove locking correctness
