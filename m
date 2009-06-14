From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Compilation of Realtek r8169-6.010.00 fails on 2.6.30
Date: Mon, 15 Jun 2009 00:31:59 +0200
Message-ID: <20090614223159.GA25800@electric-eye.fr.zoreil.com>
References: <4A342800.8070606@archesoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Torsten Mueller <torsten@archesoft.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41981 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751593AbZFNW3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 18:29:53 -0400
Content-Disposition: inline
In-Reply-To: <4A342800.8070606@archesoft.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Torsten Mueller <torsten@archesoft.de> :
[...]
> i have problems compiling the driver for this card.
> I want to test this driver to check, if it gives more
> bandwidth in a gigabit network against the stock 2.6.30
> vanilla kernel driver.
>
> Can you lead me to a solution for this compilation problem ?

Check your LINUX_VERSION_CODE and analyze the output of

$ git log -p -- drivers/net/r8169.c | less +/netif_rx_schedule_prep

Do you have specific problems with the kernel included r8169 driver ?

The one in 2.6.30 should not be too bad (as long as your chipset
is supported of course).

-- 
Ueimor
