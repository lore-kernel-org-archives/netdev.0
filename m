From: Jeff Garzik <jgarzik@pobox.com>
Subject: major bonding bug?
Date: Tue, 30 Dec 2003 11:31:15 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031230163115.GA10216@gtf.org>
References: <E791C176A6139242A988ABA8B3D9B38A014C965E@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Noam, Amir" <amir.noam@intel.com>, "Marom, Noam" <noam.marom@intel.com>,
        netdev@oss.sgi.com, fubar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hen, Shmulik" <shmulik.hen@intel.com>
Content-Disposition: inline
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A014C965E@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hmmm...

It looks like a lot of code now depends on global variable "bond_mode".

This looks very wrong...  bonding mode should be per-interface, not
global to the entire driver.  What happens when a user wants
BOND_MODE_ROUNDROBIN on bond0, and BOND_MODE_TLB on bond1?

	Jeff
