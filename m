From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: [Bonding-devel] Re: [bonding] compatibilty issues
Date: Wed, 1 Oct 2003 14:26:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031001182610.GA25218@calma.pair.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A464F2@hasmsx403.iil.intel.com> <200310011149.04612.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, "Chad N. Tindel" <chad@tindel.net>,
        fubar@us.ibm.com, jgarzik@pobox.com,
        bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmulik Hen <shmulik.hen@intel.com>
Content-Disposition: inline
In-Reply-To: <200310011149.04612.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> So here is what I did in the meantime:
> * Created a version for 2.4 that puts back all old compatibility stuff 
>   that was removed either during the propagation set or the cleanup 
>   set.
> * Created a version for 2.6 that puts back just the compatibility 
>   stuff that was removed in the propagation set (BOND_SETHWADDR, since 
>   we got a complaint from a RH9 user).
> * Removed the mention of the multicast param from the read-me.
> * Raised the ABI version to 2 so the new ifenslave keeps propagating 
>   IP settings to slaves for older drivers, and doesn't do that for new 
>   ones that contain Willy Tarreau's panic fix.

I like this.

Chad
