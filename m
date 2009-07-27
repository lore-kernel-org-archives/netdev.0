From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: WakeOnLan fix for the 8168
Date: Sun, 26 Jul 2009 20:19:14 -0700 (PDT)
Message-ID: <20090726.201914.110188393.davem@davemloft.net>
References: <20090724223419.GA13085@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tavvva@volny.cz, edward_hsu@realtek.com.tw
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49053
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755461AbZG0DTH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jul 2009 23:19:07 -0400
In-Reply-To: <20090724223419.GA13085@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 25 Jul 2009 00:34:19 +0200

> More stuff for http://bugzilla.kernel.org/show_bug.cgi?id=3D9512
>=20
> Some 8168 are unable to WoL when receiving is not enabled (plain
> old 8169 do not seem to care).
>=20
> It is not exactly pretty to leave the receiver enabled but we
> should now enable DMA late enough for it to be safe. Some late
> stage boot failure due to pxe and friends may benefit from the
> delayed enabling of bus-mastering as well.
>=20
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Jarom=EDr C=E1p=EDk <tavvva@volny.cz>

Applied.
