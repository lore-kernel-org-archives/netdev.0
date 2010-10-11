From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ATM: solos-pci, remove use after free
Date: Mon, 11 Oct 2010 11:12:36 -0700 (PDT)
Message-ID: <20101011.111236.183050557.davem@davemloft.net>
References: <1286783444-7719-1-git-send-email-jslaby@suse.cz>
	<1286785169.2737.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jslaby@suse.cz, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	chas@cmf.nrl.navy.mil
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47179
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755828Ab0JKSMP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 14:12:15 -0400
In-Reply-To: <1286785169.2737.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Oct 2010 10:19:29 +0200

> Le lundi 11 octobre 2010 =E0 09:50 +0200, Jiri Slaby a =E9crit :
>> Stanse found we do in console_show:
>>   kfree_skb(skb);
>>   return skb->len;
>> which is not good. Fix that by remembering the len and use it in the
>> function instead.
>>=20
>> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
>> Cc: Chas Williams <chas@cmf.nrl.navy.mil>
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
