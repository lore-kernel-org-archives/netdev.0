From: Bernie Innocenti <bernie@codewiz.org>
Subject: Re: ath9k: DMA failed to stop in 10 ms AR_CR=0x00000024
 AR_DIAG_SW=0x00000020
Date: Fri, 25 Dec 2009 08:38:39 -0800
Message-ID: <1261759119.7700.3.camel@giskard>
References: <9c8bade79e471eb0576625586eef7d31.squirrel@vimassive.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andy@vimassive.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.develer.com ([83.149.158.210]:55828 "EHLO
	trinity.develer.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbZLYQit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2009 11:38:49 -0500
In-Reply-To: <9c8bade79e471eb0576625586eef7d31.squirrel@vimassive.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-25 at 10:52 -0500, Andy Gussie wrote:
> I am having this same issue with a ACER 5517-5086 labtop computer. It
> seems like when I start downloading files (high network utilization)
> the network connection drops and network manager keeps requesting
> reconnection password.
> has any one been able to figure out what is causing this issue? Is
> there a fix?

I installed an updated ath9k driver from compat-wireless-2.6.32-rc7, and
the problem disappeared. Now I've been running for a few weeks without
any issue.

The fix, whatever it is, does not seem to have made it to the official
2.6.32 or the Fedora kernel.


> Dmesg
> ath9k: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x00000020
> 
> lspci -vnn
> 
> 02:00.0 Network controller [0280]: Atheros Communications Inc. AR9285
> Wireless Network Adapter (PCI-Express) [168c:002b] (rev 01)
> 	Subsystem: Foxconn International, Inc. Device [105b:e016]
> 	Flags: bus master, fast devsel, latency 0, IRQ 16
> 	Memory at 91100000 (64-bit, non-prefetchable) [size=64K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: ath9k
> 	Kernel modules: ath9k
> 
> ubuntu 9.10
> 
> uname -a
> Linux sheba 2.6.31-16-generic #53-Ubuntu SMP Tue Dec 8 04:01:29 UTC 2009 i686 GNU/Linux

-- 
   // Bernie Innocenti - http://codewiz.org/
 \X/  Sugar Labs       - http://sugarlabs.org/

