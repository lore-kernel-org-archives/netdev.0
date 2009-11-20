From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 22:43:55 +0100
Message-ID: <4B070D9B.60409@gmail.com>
References: <20091120133245.GA9038@ff.dom.local> <4B06AB96.8040805@gmail.com> <20091120200434.GB2688@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34562 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387AbZKTVn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 16:43:56 -0500
In-Reply-To: <20091120200434.GB2688@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Fri, Nov 20, 2009 at 03:45:42PM +0100, Eric Dumazet wrote:
>> Jarek Poplawski a =E9crit :
>>> On 20-11-2009 00:46, Eric Dumazet wrote:
>>> scheduled) IPIs?
>> Repeat after me :
>>
>> lockdep is my friend, lockdep is my friend, lockdep is my friend... =
:)
>=20
> Hmm... Actually, why did I have to do lockdep's job...

In fact I could not find why irq masking is necessary, and lockdep is
fine with my code and my testings. Care to explain what problem you spo=
tted ?


In fact, I originally used  cmpxchg() and xchg() (no spinlock),
but had to find the end of skb list in the IPI handler, so I chose
to use a skb_head instead to let the IPI handler be as short as possibl=
e.

