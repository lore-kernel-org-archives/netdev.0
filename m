From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: Limit how much data we copy onto the stack.
Date: Thu, 28 Oct 2010 11:32:37 -0700 (PDT)
Message-ID: <20101028.113237.193691913.davem@davemloft.net>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
	<1288279242-22153-1-git-send-email-nelhage@ksplice.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, robert.olsson@its.uu.se,
	andy.shevchenko@gmail.com, netdev@vger.kernel.org,
	eugene@redhat.com
To: nelhage@ksplice.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44676
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761286Ab0J1ScO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 14:32:14 -0400
In-Reply-To: <1288279242-22153-1-git-send-email-nelhage@ksplice.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson Elhage <nelhage@ksplice.com>
Date: Thu, 28 Oct 2010 11:20:42 -0400

> A program that accidentally writes too much data to the pktgen file can overflow
> the kernel stack and oops the machine. This is only triggerable by root, so
> there's no security issue, but it's still an unfortunate bug.
> 
> printk() won't print more than 1024 bytes in a single call, anyways, so let's
> just never copy more than that much data. We're on a fairly shallow stack, so
> that should be safe even with CONFIG_4KSTACKS.
> 
> Signed-off-by: Nelson Elhage <nelhage@ksplice.com>

Applied, thanks a lot.
