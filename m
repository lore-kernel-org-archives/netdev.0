From: Peter Missel <peter.missel@onlinehome.de>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Tue, 3 Jul 2007 20:00:51 +0200
Message-ID: <200707032000.52243.peter.missel@onlinehome.de>
References: <200704162241.31729.peter.missel@onlinehome.de> <200707022207.01132.peter.missel@onlinehome.de> <20070702215621.GA18766@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jens Stroebel <drifter@bcsoft.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:54308 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601AbXGCSBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 14:01:03 -0400
In-Reply-To: <20070702215621.GA18766@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois!

> Peter Missel <peter.missel@onlinehome.de> :
>
> > Unfortunately I couldn't get NFS to work with the updated kernel, so I
> > had to revert to the original from SuSE 10.2.
>
> No NFS but networking or no networking at all ?

Networking in itself was fine and stable, and with seemingly much better 
performance in large file transfers as well.

The system log shows the occasional "APIC error on CPU0" that didn't seem to 
do any harm at all, except once where it then said it had disabled the PCI 
IRQ for the Realtek LAN chip. This is not seen on 2.6.18, and occurred only 
once with (I think) the original, unpatched r8169 driver from 2.6.21.5. With 
the patched driver, just the "APIC error" message appears with no device 
related information at all, so I can't really say whether this is anything to 
do with the Realtek LAN at all.

NFS appeared to be working too, problem was just that workstation and server 
couldn't agree on file locking procedures anymore, and all existing files 
could only be read but not written to. This proved quite unproductive, so I 
had to revert.

regards,
Peter
