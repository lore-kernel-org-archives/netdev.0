From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's
	source MAC
Date: Mon, 28 Feb 2011 11:32:56 -0500
Message-ID: <20110228163255.GJ11864@gospo.rdu.redhat.com>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com> <20110225222455.GI11864@gospo.rdu.redhat.com> <4D683653.4050409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jay Vosburgh <fubar@us.ibm.com>, Jiri Pirko <jpirko@redhat.com>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755070Ab1B1QdO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 11:33:14 -0500
Content-Disposition: inline
In-Reply-To: <4D683653.4050409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 26, 2011 at 12:08:03AM +0100, Nicolas de Peslo=FCan wrote:
> Le 25/02/2011 23:24, Andy Gospodarek a =E9crit :
[...]
>>
>> I confirmed your suspicion, this breaks ARP monitoring.  I would sti=
ll
>> welcome other opinions though as I think it would be nice to fix thi=
s as
>> low as possible.
>
> Why do you want to fix it earlier that in ndisc_recv_ns drop? Your=20
> original idea of silently dropping the frame there seems perfect to m=
e.
>

Maybe it's just me, but I cannot understand why we want a bunch of extr=
a
packets floating up into the stack when they may only create issues for
the recipients of these duplicate frames.

Clearly my original patch needs to be refined so ARP monitoring still
works, but I would rather fix the issue there than in a higher layer.


