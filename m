From: =?utf-8?B?RnJhbsOnb2lz?= Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 misleading firmware error messages
Date: Sat, 16 Apr 2011 13:04:54 +0200
Message-ID: <20110416110454.GC17833@electric-eye.fr.zoreil.com>
References: <4DA952D5.7030805@joco.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Fejes =?utf-8?Q?J=C3=B3zsef?= <fejes@joco.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49618 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759297Ab1DPLMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 07:12:41 -0400
Content-Disposition: inline
In-Reply-To: <4DA952D5.7030805@joco.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 16, 2011 at 10:27:01AM +0200, Fejes J=C3=B3zsef wrote:
[...]
> So then I installed the rtl_nic firmware files, and the error
> messages were gone.
>=20
> How do I know if it actually tries to load the firmware at all?

Currently: remove it and the driver will tell you that it could not
load the firmware.

It's a bit rough. I'll report something through ethtool (-i).

> I see there's a condition, if an rtl_readphy returns a wrong value, i=
t
> doesn't even try to load the firmware and just prints the message.
> Although this wouldn't explain why the error message disappeared
> when the files were there.

I don't get your point.

> Clearly, my device works without these firmware files. If my device
> works better with them, or if there are other similar devices which
> require it, I think there should be a configuration option to
> disable this firmware stuff and its benefits altogether so that it
> doesn't even report that it needs it.

The driver uses netif_warn, not netif_err.

I think the driver is nevrotic enough as is and I will not add
what I consider a silly if not unusable configuration option.

=46eel free to send patches if you think they really add some
value.

--=20
Ueimor
