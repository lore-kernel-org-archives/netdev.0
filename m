From: David Gibson <david@gibson.dropbear.id.au>
Subject: [0/8] orinoco driver updates
Date: Wed, 12 Jan 2005 16:23:52 +1100
Message-ID: <20050112052352.GA30426@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: orinoco-devel@lists.sourceforge.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263021AbVALF3s@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following are a bunch of patches which make a few more steps towards
the long overdue merge of the CVS orinoco driver into mainline.  These
do make behavioural changes to the driver, but they should all be
trivial and largely cosmetic.

Jeff, please apply.  Patches are against the netdev BK tree.

orinoco-printks
	Update printk()s and other cosmetic strings
orinoco-carrier
	Use netif_carrier_() functions instead of homegrown connected
	flag
orinoco-delays
	Use mdelay() and ssleep() instead of schedule_timeout() and
	other more complicated idioms.
orinoco-free-orinocodev
	Introduce free_orinocodev() function as a wrapper around
	free_netdev()
orinoco-cleanup-hermes
	Make cleanups to low-level driver code
orinoco-pccard-cleanups
	Cleanup initialization for PCMCIA/PC-Card devices.
orinoco-modparm
	Replace obsolete MODULE_PARM() constructions from orinoco.c
orinoco-pci-updates
	Cleanup initialization for PCI/PLX/TMD devices.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson
