From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 07:29:13 +0200
Message-ID: <20091016052913.GB5574@1wt.eu>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli> <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli> <4AD7EDB4.7060907@gmail.com> <4AD7FE01.1010805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50271 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752774AbZJPFaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 01:30:01 -0400
Content-Disposition: inline
In-Reply-To: <4AD7FE01.1010805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2009 at 07:00:49AM +0200, Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
> >=20
> >=20
> > So, it appears defer_accept value is not an inherited attribute,
> > but shared by all embryons. Therefore we should not touch it.
> >=20
> > Of course it should be done, or add a new connection field to count=
 number
> > of pure ACKS received on each SYN_RECV embryon.
> >=20
>=20
> Could be something like this ? (on top of net-next-2.6 of course)
>=20
> 7 bits is more than enough, we could take 5 bits IMHO.

Couldn't we just rely on the retrans vs rskq_defer_accept comparison ?

Willy

