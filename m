From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Remove sleep at .ndo_get_stats
Date: Tue, 27 Sep 2011 00:47:09 -0400 (EDT)
Message-ID: <20110927.004709.1461629832092889464.davem@davemloft.net>
References: <1317066179.2796.9.camel@edumazet-laptop>
	<1317067863-11706-1-git-send-email-brenohl@br.ibm.com>
	<1317068935.2796.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brenohl@br.ibm.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861Ab1I0ErP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 00:47:15 -0400
In-Reply-To: <1317068935.2796.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 26 Sep 2011 22:28:55 +0200

> Le lundi 26 septembre 2011 =E0 17:11 -0300, brenohl@br.ibm.com a =E9c=
rit :
>> Currently ehea ndo_get_stats can sleep in two places, in a hcall
>> and in a GFP_KERNEL alloc, which is not correct.
>> This patch creates a delayed workqueue that grabs the information ea=
ch 1
>> sec from the hardware, and place it into the device structure, so th=
at,
>> .ndo_get_stats quickly returns the device structure statistics block=
=2E
>>=20
>> Signed-off-by: Breno Leitao <brenohl@br.ibm.com>
>> ---
>=20
> Seems good, thanks
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
