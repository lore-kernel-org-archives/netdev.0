From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] r8169: use device model DMA API
Date: Sat, 09 Oct 2010 09:17:26 -0700 (PDT)
Message-ID: <20101009.091726.13735252.davem@davemloft.net>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
	<1286547901-10782-2-git-send-email-sgruszka@redhat.com>
	<1286611056.2692.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sgruszka@redhat.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33069
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756498Ab0JIQRE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Oct 2010 12:17:04 -0400
In-Reply-To: <1286611056.2692.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 09 Oct 2010 09:57:35 +0200

> Le vendredi 08 octobre 2010 =E0 16:25 +0200, Stanislaw Gruszka a =E9c=
rit :
>> Use DMA API as PCI equivalents will be deprecated. This change also
>> allow to allocate with GFP_KERNEL where possible.
>>=20
>> Tested-by: Neal Becker <ndbecker2@gmail.com>
>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
>> ---
>>  drivers/net/r8169.c |   53 +++++++++++++++++++++++++++-------------=
----------
>>  1 files changed, 29 insertions(+), 24 deletions(-)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
