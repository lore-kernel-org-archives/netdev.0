From: David Gibson <david@gibson.dropbear.id.au>
Subject: [0/5] Orinoco merge updates, part the fourth
Date: Wed, 30 Mar 2005 13:42:38 +1000
Message-ID: <20050330034238.GF6478@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>,
	Orinoco Development List <orinoco-devel@lists.sourceforge.net>,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261751AbVC3Dqa@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff, please apply:

Here's yet another batch of orinoco updates.  Smaller and less
significant than the last, this is basically a handful of remaining
small updates before tackling the big changes (wext v15, monitor and
scanning).  Patches are:
	orinoco-wstats-updates
		Updates and bugfixes to wireless stats handling
	orinoco-ignore-disconnect
		Add the ignore_disconnect module parameter
	orinoco-kill-dump-recs
		Remove ugly debugging code, to be replaced later with
		simpler and more useful stuff
	orinoco-no-infra-channel
		Don't attempt to set channel in managed mode, the
		firmware doesn't like that.
	orinoco-consolidate-allocate
		Remove some duplicated code for firmware buffer
		allocation, removing a bug in a hw workaround in the
		process.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson
