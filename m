From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [E1000-devel] e1000e interface hang on 82574L
Date: Mon, 19 Mar 2012 16:29:03 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6260E512FB9@ORSMSX102.amr.corp.intel.com>
References: <4EFA4024.5000909@bootc.net>
	<FCF3184D-CE4F-471C-B66C-0F671795FD3C@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B626017762@ORSMSX102.amr.corp.intel.com>
	<4F048861.8070501@bootc.net> <4F12B42C.9030803@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B62621F0B1@ORSMSX102.amr.corp.intel.com>
	<4F144A76.3050703@bootc.net> <4F64B4E2.20208@bootc.net>
	<4F64CFCB.7060702@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B6260E512E0C@ORSMSX102.amr.corp.intel.com>
 <87r4wova0b.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Chris Boot <bootc@bootc.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Nix <nix@esperi.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87r4wova0b.fsf@spindle.srvr.nix>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>-----Original Message-----
>From: Nix [mailto:nix@esperi.org.uk]
>Sent: Monday, March 19, 2012 9:20 AM
>To: Wyborny, Carolyn
>Cc: Chris Boot; e1000-devel@lists.sourceforge.net; netdev; lkml
>Subject: Re: [E1000-devel] e1000e interface hang on 82574L
>
[...]

>you'll see that I tested that, and it doesn't work :( even if it did
>work, it shouldn't be needed: the driver attempts to turn off PCIe ASPM
>on affected NICs, and fails, apparently because *something* turns it
>back on again.
>
>--
>NULL && (void)

The driver attempts to disable L0s state, not the entire feature.  It is also required that the device upstream on the bus from the 82574L have this disabled.  Yes, I agree there appears to be something in the os that either ren-enables or fails to disable the feature on the upstream device, as desired.  Platforms/systems also appear to vary in this regard, so the solutions may vary a bit as well.  

Its worth trying your solution as well if what I suggested doesn't work, but there is not one solution that fits all, unfortunately.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation
