From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [Bonding-devel] Re: [bonding] compatibilty issues
Date: Thu, 2 Oct 2003 09:37:51 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310020937.51781.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A464F9@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jay Vosburgh" <fubar@us.ibm.com>, "David S. Miller" <davem@redhat.com>,
        "Chad N. Tindel" <chad@tindel.net>, <jgarzik@pobox.com>,
        <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A02A464F9@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 01 October 2003 10:25 pm, Jay Vosburgh wrote:
> 	Same here, but I'd like to have a list somewhere of what each
> of the ABI versions is for and how they're supposed to behave. 
> It's starting to look like we're going to be adding these on a
> semi-regular basis, so we need to keep track of what each one does
> and why.
>

Where should such a list go ?
Currently, 0 or none is for doing everything the old way.
1 is for not setting slaves HW addr via ifenslave and leaving them in 
down state so the driver gets them with their unique address, sets 
them according to the mode and brings them up. The driver also 
restores the original address upon release. This is all done for 
supporting the 802.3ad, TLB, ALB modes.
2 will be for ifenslave lite that doesn't propagate the bond's IP 
settings to the slaves.
I'm guessing that 3 will be used to designate the new support for hot 
operations that Amir is working on.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
