From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: 2.6.27 [BUG-FIX] [PATCH 1/1] dccp: Port redirection support
	for?DCCP
Date: Sat, 18 Oct 2008 12:06:51 +0200
Message-ID: <20081018100651.GA23003@gerrit.erg.abdn.ac.uk>
References: <20081018092118.GA22685@gerrit.erg.abdn.ac.uk> <200810181148.14620@nessa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:41327 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750878AbYJRKG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 06:06:59 -0400
Content-Disposition: inline
In-Reply-To: <200810181148.14620@nessa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| I think we're still missing this one:
| 
| diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
| index 1106278..aa00cdd 100644
| --- a/net/dccp/ipv6.c
| +++ b/net/dccp/ipv6.c
| @@ -558,7 +558,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
|  		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
|  		fl.oif = sk->sk_bound_dev_if;
|  		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
| -		fl.fl_ip_sport = inet_sk(sk)->sport;
| +		fl.fl_ip_sport = inet_rsk(req)->loc_port;
|  		security_sk_classify_flow(sk, &fl);
|  
|  		if (ip6_dst_lookup(sk, &dst, &fl))
| 
| What do you think?
Ack - missed this one. Do you want to send your patch or would you like
me to send an update for the above?

Thanks
Gerrit
