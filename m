From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Bonding-devel] [PATCH] [bonding 2.4] fix creating/destroying
 the /proc/net/bonding dir
Date: Fri, 31 Oct 2003 11:47:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031031114715.55a38c7f.davem@redhat.com>
References: <200310231739.42556.amir.noam@intel.com>
	<200310311934.h9VJYMTs016412@death.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: amir.noam@intel.com, jgarzik@pobox.com,
        bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200310311934.h9VJYMTs016412@death.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I think it's not worthwhile trying to break procfs handling
wrt. any kind of network devices in 2.4.x, there are lots
of known far reaching problems in this area (none of which
are bonding specific) that require large intrusive changes
to fix and therefore are not likely to be cured in the 2.4.x
tree.

Simply stated, references to procfs files do not create the
necessary references to the network devices they are created
for and therefore anything stressing this sort of thing
is going to explode.

We fixed all of this in 2.6.x
