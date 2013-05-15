From: Ken Moffat <zarniwhoop@ntlworld.com>
Subject: Re: r8169 on 3.8.13, 3.9.2, 3.10-rc1, was Re: [ 00/73] 3.8.13-stable
 review
Date: Wed, 15 May 2013 18:09:47 +0100
Message-ID: <20130515170947.GA10174@milliways>
References: <20130509222757.917088509@linuxfoundation.org>
 <pan.2013.05.10.10.54.26.943195@googlemail.com>
 <20130515000715.GA20099@milliways>
 <20130515061401.GA4382@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Holger Hoffstaette <holger.hoffstaette@googlemail.com>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130515061401.GA4382@electric-eye.fr.zoreil.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 15, 2013 at 08:14:01AM +0200, Francois Romieu wrote:
> Ken Moffat <zarniwhoop@ntlworld.com> :
> [...]
> >  Cc'ing to netdev because I don't think this has had a response, an=
d
>=20
> A patch has been sent to netdev a few hours ago. It needs more work,
> especially testing (hint, hint) as I don't have a proven test case ye=
t.
>=20
> Please note:
> - if you don't use a 8168evl (check your dmesg for the XID line emitt=
ed
>   by the r8169 driver), you are not the experiencing the same bug.
[    3.174180] r8169 0000:02:00.0 eth0: RTL8168evl/8111evl at
0xffffc90000008000, c8:60:00:97:07:35, XID 0c900800 IRQ 41

> - if you don't enable Tx checksum offload (distro/vendor dependent th=
ough
>   disabled by default in the vanilla driver, see ethtool -k eth0,
>   ethtool -K eth0 tx on sg on)), you are not the experiencing the sam=
e
>   bug.

 If it is disabled by default then my problem is different (I don't
have an ethtool program)

> - if you are experiencing the same bug, 3.10-rc1 should work again
>   after reverting e5195c1f31f399289347e043d6abf3ffa80f0005
>=20
> If someone comes with a failing network capture and a working one, it=
 will
> save time. A 64 bytes (max) packet is not correctly transmitted.
>=20
> --=20
> Ueimor

 Thanks for the detailed comments, looks as if my intermittent
problem is something else.

ken
--=20
das eine Mal als Trag=F6die, das andere Mal als Farce
