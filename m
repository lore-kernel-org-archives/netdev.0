From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: major bonding bug?
Date: Tue, 30 Dec 2003 16:03:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312310003.hBV03SJ0015202@death.nxdomain.ibm.com>
References: <amir.noam@intel.com>
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
        "Hen,
    Shmulik" <shmulik.hen@intel.com>,
        "Marom,
    Noam" <noam.marom@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Amir Noam <amir.noam@intel.com>
In-Reply-To: Message from Amir Noam <amir.noam@intel.com>
   of "Tue, 30 Dec 2003 18:45:14 +0200." <200312301845.14275.amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>> This looks very wrong...  bonding mode should be per-interface, not
>> global to the entire driver.  What happens when a user wants
>> BOND_MODE_ROUNDROBIN on bond0, and BOND_MODE_TLB on bond1?
>
>We agree that it looks very wrong, and this is in fact one of the 
>features we've been working on lately. It is not a trivial fix, 
>since, as you've noted, a lot of the code depends on the bond 
>settings being global. We plan to start releasing patches to address 
>this issue very soon (probably even starting tomorrow).

	FWIW, the workaround is to load the bonding module multiple
times (once for each desired mode).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
