From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: cx82310_eth: use common match macro"
Date: Thu, 19 Mar 2015 12:27:38 -0400 (EDT)
Message-ID: <20150319.122738.693681731967137389.davem@davemloft.net>
References: <1426716061-20953-1-git-send-email-linux@rainbow-software.org>
	<87y4mtcs8l.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux@rainbow-software.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bjorn@mork.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y4mtcs8l.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 19 Mar 2015 09:21:30 +0100

> Ondrej Zary <linux@rainbow-software.org> writes:
>=20
>> This reverts commit 11ad714b98f6d9ca0067568442afe3e70eb94845 because
>> it breaks cx82310_eth.
>>
>> The custom USB_DEVICE_CLASS macro matches
>> bDeviceClass, bDeviceSubClass and bDeviceProtocol
>> but the common USB_DEVICE_AND_INTERFACE_INFO matches
>> bInterfaceClass, bInterfaceSubClass and bInterfaceProtocol instead, =
which are
>> not specified.
>=20
> Ouch.  What ever made me do that? Thanks a lot for fixing it!
>=20
> This bug was introduced as long ago as v3.7, so the fix should go int=
o
> every currently maintained stable branch since that.

Queued up for -stable, thanks.
