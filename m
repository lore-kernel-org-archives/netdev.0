From: David Miller <davem@davemloft.net>
Subject: Re: To GRO or not to GRO...
Date: Sun, 03 Oct 2010 00:31:29 -0700 (PDT)
Message-ID: <20101003.003129.193711520.davem@davemloft.net>
References: <4CA7BD60.3010501@sauce.co.nz>
	<152341286090326@web67.yandex.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richard@sauce.co.nz, netdev@vger.kernel.org
To: sysoleg@yandex.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46089
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751998Ab0JCHbI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Oct 2010 03:31:08 -0400
In-Reply-To: <152341286090326@web67.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Date: Sun, 03 Oct 2010 11:18:46 +0400

>=20
>=20
> 03.10.2010, 03:17, "Richard Scobie" <richard@sauce.co.nz>:
>=20
>> In the README for ixgbe-2.1.4, is says:
>>
>> " Disable GRO when routing/bridging
>> =A0=A0=A0---------------------------------
>> =A0=A0=A0Due to a known kernel issue, GRO must be turned off when
>> routing/bridging.
>> =A0=A0=A0GRO can be turned off via ethtool."
>>
>=20
> This information is true for LRO, not GRO.

Right.

> I believe that this appeared when ixgbe was converted from LRO
> to GRO and all occurrences of LRO was blindly replaced by GRO
> everywhere.

Someome please submit a patch to fix this, thanks.
