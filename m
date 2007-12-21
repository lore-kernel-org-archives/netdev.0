From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [TCP] tcp_write_timeout.c cleanup
Date: Fri, 21 Dec 2007 11:14:44 -0200
Message-ID: <20071221131444.GV6264@ghostprotocols.net>
References: <476B5581.6040603@cosmosbay.com> <20071221122316.GU6264@ghostprotocols.net> <20071221.043026.19571736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42761 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752539AbXLUNPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 08:15:15 -0500
Content-Disposition: inline
In-Reply-To: <20071221.043026.19571736.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Dec 21, 2007 at 04:30:26AM -0800, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Fri, 21 Dec 2007 10:23:16 -0200
> 
> > Em Fri, Dec 21, 2007 at 06:56:17AM +0100, Eric Dumazet escreveu:
> > > +static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
> > > +{
> > > +	int mss;
> > -       int mss;
> > 		
> > > +
> > > +	/* Black hole detection */
> > > +	if (sysctl_tcp_mtu_probing) {
> > > +		if (!icsk->icsk_mtup.enabled) {
> > > +			icsk->icsk_mtup.enabled = 1;
> > > +			tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
> > > +		} else {
> > > +			struct tcp_sock *tp = tcp_sk(sk);
> > +			int mss;
> > > +			mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low)/2;
> 
> I've checked in this, ummm... patch :-)

Thanks!

- Arnaldo
