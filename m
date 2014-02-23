From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] tcp: switch rtt estimations to usec
 resolution
Date: Sun, 23 Feb 2014 21:11:13 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1402232102370.1460@ja.home.ssi.bg>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg> <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35771 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751295AbaBWTLn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Feb 2014 14:11:43 -0500
In-Reply-To: <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 23 Feb 2014, Eric Dumazet wrote:

> > 	What is the way to handle this change of
> > resolution in TCP_METRICS_ATTR_VALS? The ip tool has
> > code in ip/tcp_metrics.c process_msg() that needs to
> > know what we get, ms or us. Do we need to add some
> > new attribute as flag or version? Or we need to increase
> > TCP_METRICS_GENL_VERSION in kernel and to check it in
> > process_msg ?
> 
> crap... This should have been usec units as we did for tcp_info years
> ago.
> 
> Solution is to add TCP_METRIC_RTT_US and TCP_METRIC_RTTVAR_US attributes
> 
> I'll send a v2

	What about ip/iproute.c, according to tcpm_suck_dst
print_route and iproute_modify use the same ms-based units.

Regards

--
Julian Anastasov <ja@ssi.bg>
