From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 13:49:18 -0800 (PST)
Message-ID: <20091120.134918.150129042.davem@davemloft.net>
References: <4B0701E2.1070806@gmail.com>
	<4B070BAC.1090406@gmail.com>
	<1258753414.28239.66.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, jarkao2@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51697
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754841AbZKTVtA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 16:49:00 -0500
In-Reply-To: <1258753414.28239.66.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Joe Perches <joe@perches.com>
Date: Fri, 20 Nov 2009 13:43:34 -0800

> On Fri, 2009-11-20 at 22:35 +0100, Eric Dumazet wrote:
>> Jarek Poplawski a =E9crit :
>> > There is one more problem: this will break things like act_mirred =
+ ifb,
>> > and other cases using skb->iif e.g. for filtering on virtual devic=
es at
>> > the xmit path.
>> Following patch might help us to locate real uses of this obscure fi=
eld :)
>> [PATCH net-next-2.6] net: rename skb->iif to skb->skb_iif
>=20
> Prefixing member names generally doesn't end well.
> Prefixing selected member names? ick.

But I highly encourage what Eric is doing, I hate having to grep the
tree very carefully just to find uses of a certain SKB struct member.

And since SKB usage covers so many thousands of files in the tree,
doing one at a time like Eric is here really can make sense.
