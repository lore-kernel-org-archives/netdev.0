From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_RAW: Augment raw_send_hdrinc to expand skb to fit
 iphdr->ihl (v2)
Date: Thu, 29 Oct 2009 01:10:14 -0700 (PDT)
Message-ID: <20091029.011014.222504422.davem@davemloft.net>
References: <4AE889B5.4040301@gmail.com>
	<20091028185947.GA12675@hmsreliant.think-freely.org>
	<4AE8B114.6050504@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37199
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752887AbZJ2IJu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 04:09:50 -0400
In-Reply-To: <4AE8B114.6050504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Oct 2009 22:01:08 +0100

> Neil Horman a =E9crit :
>>=20
>>> I believe we should drop the request, since padding it is not what =
was expected by user.
>>=20
>> Yeah, I had a feeling.  Ok, version 2, this time drop the invalid fr=
ame and
>> report it to user space, instead of expanding it:
>>=20
>>=20
>>     Augment raw_send_hdrinc to correct for incorrect ip header lengt=
h values
 ...
>>     Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20

Applied to net-2.6, thanks everyone!
