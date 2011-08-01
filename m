From: Alan Cox <alan@linux.intel.com>
Subject: Re: [net-next v2 02/71] 3c*/acenic/typhoon: Move 3Com Ethernet
 drivers
Date: Mon, 1 Aug 2011 10:42:03 +0100
Message-ID: <20110801104203.6c0dcbac@bob.linux.org.uk>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1312082850-24914-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<20110801100303.48ed75f7@bob.linux.org.uk>
	<20110801.022107.740149515523315115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, philb@gnu.org,
	klassert@mathematik.tu-chemnitz.de, dave@thedillows.org,
	jes@trained-monkey.org, becker@scyld.com,
	craigs@ineluki.apana.org.au, dahinds@users.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45636 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753484Ab1HAJjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2011 05:39:25 -0400
In-Reply-To: <20110801.022107.740149515523315115.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Aug 2011 02:21:07 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Alan Cox <alan@linux.intel.com>
> Date: Mon, 1 Aug 2011 10:03:03 +0100
> 
> > And even if you wanted to make Kconfig simpler - you don't need to
> > move files around.
> 
> The point is to move the files around, so that drivers/net/ isn't
> a turd pond.
> 
> I agree with some of your feedback, but I disagree with a wholesale
> rejecting the idea of untangling the mess under drivers/net/ as that's
> the main reason why I want Jeff's work to be done

In which case I think I'd sort by chipset for the non bus distinct
ones. That also has the added advantage that all the annoying weird
crap disappears into its own subdirectories for ancient chipsets !

So my suggestion would be :

Create an i82586 directory
Stick the following into it
	3c505 3c507 3c523 3c527 eepro eexpress ni52 sun3_82586 znet

Create an i82596 directory
Stick the following into it
	82596 lasi_82596 lib82596 lp486e sni_82596

Create an ns8390 directory
Stick the following into it
	3c503 8390 8390p ac3200 apne aax88796 e2100 es3210 hp hp-plus
	hydra lib8390 lne390 mac8390 ne ne2 ne2k-pci ne3210 ne-h8300
	smc-mca smc-ultra32 smc-ultra stnic wd zorro8390

Create a sonic directory (sadly nobody ever produced a screwdriver card)
Stick the following into it
	jazzsonic macsonic sonic xtsonic

Create a lance directory (actually this is 7990 + lance32 etc)
Stick the following into it
	7990.c a2065 ariadne atarilance declance hplance lance mvme147
	ni65 pcnet32 sun3lance sunlance


Some bits are then sort of bustypeish

Create a parallel directory
Stick the following into it
	atp de600 de620 plip

Create a ppp directory
Stick all the ppp bits in

Given x25_asy is in WAN perhaps slip should be there too ?


