From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Tue, 7 Jan 2014 06:03:31 -0800 (PST)
Message-ID: <1389103411.55503.YahooMailBasic@web125502.mail.ne1.yahoo.com>
References: <20140107130101.GD24730@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm47.bullet.mail.ne1.yahoo.com ([98.138.120.54]:36776 "HELO
	nm47.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751647AbaAGOG3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 09:06:29 -0500
In-Reply-To: <20140107130101.GD24730@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1/7/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote=
:

>> Anyway, although I think that this solution is valid, I
>> am testing another way to do this change.
=20
> Ok, thanks for explaining, I see now, of course.
=20
> Maybe we could just do=20
> (ipv6_addr_type(addr) & IPV6_ADDR_LINKLOCAL) ? skb->dev : NULL?
=20
> I guess the NULL solution would be ok now, too. You can
> decide. I just  think we can be a bit more defensive here with no add=
itional
> cost. Routing table behaviour is pretty complicated and maybe can cha=
nge
> in future.
=20
I see.
first solution : I add this "defensive" update.
second solution : the v5 patch I will send soon.

Thanks for the review.
=46ran=E7ois-Xavier
