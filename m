From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: Make it easier to parse /proc/net/dev
 contents.
Date: Thu, 07 Jan 2010 00:59:29 -0800 (PST)
Message-ID: <20100107.005929.125556875.davem@davemloft.net>
References: <20100105155052.13309.1197.stgit@firesoul.comx.local>
	<4B44263D.20604@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hawk@comx.dk, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47147
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932457Ab0AGI7V convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 03:59:21 -0500
In-Reply-To: <4B44263D.20604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jan 2010 06:57:17 +0100

> Le 05/01/2010 16:50, Jesper Dangaard Brouer a =E9crit :
>> The contents of /proc/net/dev is annoying to parse, because
>> it changes whether there is a space after the "ethX:" or not.
>> It depends upon the size of the "Receive bytes" counter,
>> if the number is below 7 digits, then there is whitespaces
>> else if the number is 8 digits or above there is no space
>> between the ":" and the number.
>>=20
>> This patch changes the output to assure there is always a space
>> between the ":" and the number.  Given that all existing userspace
>> application already need to handle the whitespaces, I see
>> no breakage of existing tools.
>>=20
>> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
