From: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: [0/14] Orinoco driver updates
Date: Thu, 24 Feb 2005 14:53:55 +1100
Message-ID: <20050224035355.GA32001@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>,
	Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Jeff, please apply:

Here's a big stack of patches that make a significant step forward on
the long overdue orinoco driver merge.  Still quite a long way to go,
but it's something.  This patch stack is againt Linus' vanilla +
Viro's big iomap cleanup patch, as requested.

The first 9 patches make only trivial or cosmetic behavioural changes:
	1/14		orinoco-carrier 
		Use netif_carrier_*() macros instead of homegrown
		'connected' variable.

	2/14		orinoco-printks 
		Update various printk()s and other cosmetic strings

	3/14		orinoco-delays
		Use mdelay() and ssleep() instead of outdated ways of
		delaying.

	4/14		orinoco-free-orinocodev
		Introduce free_orinocodev() function, to reduce noise
		in future diffs.

	5/14		orinoco-cleanup-hermes
		Assorted cleanups to low-level hardware access code

	6/14		orinoco-pci-updates
		Cleanup to initialization code for the PCI based
		orinoco devices.

	7/14		orinoco-modparm
		Use modern module_parm macros for orinoco module.

	8/14		orinoco-pccard-cleanups
		Cleanup to PCMCIA initialization code

	9/14		orinoco-void-ethersnap
		Trivial change to is_ethersnap() function to reduce
		future diff noise.

The next 4 patches start to intoduce real new functionality and
bug fixes:
	10/14		orinoco-no-ibss-any
		Disallow IBSS mode if no ESSID is set (too many
		firmwares break, otherwise)

	11/14		orinoco-late-tx-wake
		Delay waking the Tx queue, fixes problems on a number
		of firwmares

	12/14		orinoco-wep-updates
		Various updates to WEP setup code

	13/14		orinoco-update-firmware-detection
		Updates and bugfixes to firmware detection logic

And the final one, is another trivial one:
	14/14		orinoco-is-now-0.14alpha2
		Update version and changelog to reflect the above
		patches.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
