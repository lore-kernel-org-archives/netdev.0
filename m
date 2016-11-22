From: <Mario.Limonciello@dell.com>
Subject: RE: [PATCH v9 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Tue, 22 Nov 2016 17:36:15 +0000
Message-ID: <f653e691805d41d190160409282ea450@ausx13mpc120.AMER.DELL.COM>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
 <20161109143632.GE6167@kw.sim.vm.gnt>
 <E607265CB020454880711A6F96C05A03B677E4C9@hasmsx107.ger.corp.intel.com>
 <20161115105920.GH6167@kw.sim.vm.gnt>
 <E607265CB020454880711A6F96C05A03BE2199EE@hasmsx108.ger.corp.intel.com>
 <20161118112007.GB1230@kw.sim.vm.gnt> <20161122172828.GB31492@kw.sim.vm.gnt>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: <gregkh@linuxfoundation.org>, <andreas.noever@gmail.com>,
        <bhelgaas@google.com>, <corbet@lwn.net>,
        <linux-kernel@vger.kernel.org>, <linux-pci@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-doc@vger.kernel.org>,
        <thunderbolt-linux@intel.com>, <mika.westerberg@intel.com>,
        <tomas.winkler@intel.com>, <xiong.y.zhang@intel.com>,
        <michael.jamet@intel.com>, <remi.rerolle@seagate.com>
To: <simon.guinot@sequanux.org>, <amir.jer.levy@intel.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20161122172828.GB31492@kw.sim.vm.gnt>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Here are a couple of additional questions:
>=20
> - When the network interface is created, there is no IP address
>   assigned (or negotiated ?) on the Linux side. But it is done on the
>   MacOS side. And in the Linux kernel logs I can also read the message:
>   "ready for ThunderboltIP negotiation". Is there something missing or
>   not working on the Linux side ? What is the correct way to configure
>   or negotiate the IP address. For my tests I did it manually...
>=20
> - When the Linux machine is started with the Thunderbolt wire already
>   connected to a MacBook Pro, sometimes (but not every time) the
>   network interface is not created. The Thunderbolt wire needs to be
>   replugged.
>=20
> FWIW you get my
>=20
> Tested-by: Simon Guinot <simon.guinot@sequanux.org>
>=20
> Simon

Simon,

Since I also performed testing on the previous patchset, I'll share what I =
did.

I configured Network Manager to use the TBT interface to share an internet
connection to another box.  This configures a static IP address on the loca=
l
Linux side and sets up routing.

Network manager remembers setup this in a configuration database. =20
When the interface goes up it will then set up a DHCP server to hand
out an IP address to the other side.


