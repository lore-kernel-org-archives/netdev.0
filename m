From: Max Krasnyansky <maxk@qti.qualcomm.com>
Subject: Re: why does kernel 3.8-rc1 put all TAP devices into state RUNNING
 during boot
Date: Mon, 7 Jan 2013 16:27:01 -0800
Message-ID: <50EB67D5.8070001@qti.qualcomm.com>
References: <50E7FD79.1080605@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50E7FD79.1080605@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/2013 02:16 AM, Toralf F=C3=B6rster wrote:
> At my stable Gentoo Linux I'm observed a change behaviour for the
> configured TAP devices after the boot process.
>=20
> $ diff 3.7.1 3.8.0-rc1+ | grep UP
>- br0: flags=3D4355<UP,BROADCAST,PROMISC,MULTICAST>  mtu 1500
>+ br0: flags=3D4419<UP,BROADCAST,RUNNING,PROMISC,MULTICAST>  mtu 1500
>- tap0: flags=3D4099<UP,BROADCAST,MULTICAST>  mtu 1500
>+ tap0: flags=3D4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
>=20
> May I ask you if this changed behaviour is intended ?

I'm not aware of any changes in this behavior.
btw Looks like it changed for your bridge interfaces as well. So it's n=
ot really
specific to the TAP devices.

Someone from netdev would know :)

Max
