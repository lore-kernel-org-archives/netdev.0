From: David Miller <davem@davemloft.net>
Subject: Re: PATCH net-next-2.6] linkwatch: linkwatch_forget_dev() to
 speedup device dismantle
Date: Wed, 18 Nov 2009 05:05:37 -0800 (PST)
Message-ID: <20091118.050537.169476840.davem@davemloft.net>
References: <20091117.042604.99618154.davem@davemloft.net>
	<20091117123133.GA14831@gondor.apana.org.au>
	<4B02C859.6020100@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53225
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756361AbZKRNFV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 08:05:21 -0500
In-Reply-To: <4B02C859.6020100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Nov 2009 16:59:21 +0100

> Herbert Xu a =E9crit :
>> On Tue, Nov 17, 2009 at 04:26:04AM -0800, David Miller wrote:
>>> Really, the link watch stuff is just due for a redesign.  I don't
>>> think a simple hack is going to cut it this time, sorry Eric :-)
>>=20
>> I have no objections against any redesigns, but since the only
>> caller of linkwatch_forget_dev runs in process context with the
>> RTNL, it could also legally emit those events.
>=20
> Thanks guys, here an updated version then, before linkwatch surgery ?

Sure, applied to net-next-2.6, thanks.
