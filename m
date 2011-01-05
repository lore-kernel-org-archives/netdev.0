From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler
Date: Wed, 5 Jan 2011 09:17:18 -0800
Message-ID: <20110105091718.02f8a00f@nehalam>
References: <20110104162930.6fa672e3@nehalam>
	<1294208375.3420.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47303 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231Ab1AERRU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 12:17:20 -0500
In-Reply-To: <1294208375.3420.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Jan 2011 07:19:35 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 04 janvier 2011 =E0 16:29 -0800, Stephen Hemminger a =E9crit=
 :
> > +static struct sk_buff *skb_peek_random(struct sk_buff_head *list)
> > +{
> > +	struct sk_buff *skb =3D list->next;
> > +	unsigned int idx =3D net_random() % list->qlen;
> > +
> > +	while (skb && idx-- > 0)
> > +		skb =3D skb->next;
> > +
> > +	return skb;
> > +}
>=20
> You could avoid the divide op :
>=20
> unsigned int idx =3D reciprocal_divide(random32(), list->qlen);

How would this work, it is a mod not a divide??

--=20
