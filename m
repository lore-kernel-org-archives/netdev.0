From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 2/5] net/cpsw: don't continue if we miss to allocate rx
 skbs
Date: Mon, 22 Apr 2013 10:05:31 +0200
Message-ID: <5174EF4B.7090800@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-3-git-send-email-bigeasy@linutronix.de> <516FDDEE.6030906@ti.com> <516FE26C.5040601@linutronix.de> <51711F0A.50204@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:56474 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754365Ab3DVIFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 04:05:34 -0400
In-Reply-To: <51711F0A.50204@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2013 12:40 PM, Mugunthan V N wrote:
> But i am seeing most of the drivers allowing to open the device with lesser
> rx skb count? But i don't know where this has been changed recently, may
> be some other network experts can comment on this.

If you configure a special value in your device tree you should obey
it or else you won't the same result.

> 
> Regards
> Mugunthan V N

Sebastian
