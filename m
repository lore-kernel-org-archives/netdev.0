From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] adi: adapt to eth_hw_addr_random() and changes
 in arch/blackfin
Date: Sun, 19 Feb 2012 19:05:04 -0500 (EST)
Message-ID: <20120219.190504.1559694496609520740.davem@davemloft.net>
References: <1329412171-20704-3-git-send-email-danny.kukawka@bisect.de>
	<CAMjpGUdAe66Nw16EyM1_dv4e8uHV02tcfqiuWL8ipeUrQ=HThg@mail.gmail.com>
	<201202171157.55585.danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vapier@gentoo.org, sonic.zhang@analog.com,
	jeffrey.t.kirsher@intel.com, bob.liu@analog.com,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201202171157.55585.danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Danny Kukawka <danny.kukawka@bisect.de>
Date: Fri, 17 Feb 2012 11:57:54 +0100

> On Freitag, 17. Februar 2012, Mike Frysinger wrote:
>> On Thu, Feb 16, 2012 at 12:09, Danny Kukawka wrote:
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_warn(ndev, "S=
etting Ethernet MAC to a
>> > random one\n"); + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 eth_=
hw_addr_random(ndev);
>>
>> would it make sense to have the core dump the warning ?
>=20
> Maybe. Many drivers already print information about setting a random =
mac=20
> address to a netdevice. Some with printk, some via=20
> netdev_warn/netdev_info/netdev_dbg or netif_dbg and other with costum=
=20
> methods. I could unify this, in a next step with a netdev_info in=20
> eth_hw_addr_random(), if it's okay for David.=20

All of these log messages are stupid and should be removed.

If someone is seriously interested in it, we have the damn random
address boolean state which can be inspected in the sysfs addr_assign_t=
ype
node for the device.

End of story.
