From: =?utf-8?B?RnJhbsOnb2lz?= Romieu
	<romieufr.zoreil.com@fr.zoreil.com>
Subject: Re: r8169 misleading firmware error messages
Date: Sun, 17 Apr 2011 16:38:39 +0200
Message-ID: <20110417143839.GA18316@electric-eye.fr.zoreil.com>
References: <4DA952D5.7030805@joco.name> <20110416110454.GC17833@electric-eye.fr.zoreil.com> <4DA9864E.2070405@joco.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Fejes =?utf-8?Q?J=C3=B3zsef?= <fejes@joco.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36848 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402Ab1DQO4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 10:56:37 -0400
Content-Disposition: inline
In-Reply-To: <4DA9864E.2070405@joco.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 16, 2011 at 02:06:38PM +0200, Fejes J=C3=B3zsef wrote:
[...]
> I meant this:
>=20
> 2233         if ((rtl_readphy(tp, 0x06) !=3D 0xbf00) ||
> 2234             (rtl_apply_firmware(tp, FIRMWARE_8168D_1) < 0)) {
> 2235                 netif_warn(tp, probe, tp->dev, "unable to apply
> firmware patch\n");
> 2236         }

Ok.

This part is about to be reworked in Linus's tree.

[...]
> I took a deeper look. It seems to me that the firmware files are not
> the usual microcode type that the device can't function without, it
> just sets up some registers, which supposedly already contain some
> sensible values, so it's more like patching. That explains why this
> device still works without the firmware. So my actual question is
> this: what do I gain if I use the firmware, what do I lose if I
> don't ?

As Ben stated, if everything seems ok with your link partner and you
do not use the firmware, using the firmware will not make things work
better.

--=20
Ueimor
