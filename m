From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v4 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Mon, 24 Feb 2014 22:47:47 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1402242240290.1941@ja.home.ssi.bg>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>  <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>  <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
  <1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com> <1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47742 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752212AbaBXUsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 15:48:00 -0500
In-Reply-To: <1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 24 Feb 2014, Eric Dumazet wrote:

> v4: switch to ktime_get() instead of ktime_get_real()

	May be you missed my last email. In tcpm_suck_dst()
dst_metric_raw(dst, RTAX_RTT) returns msecs and we store
it in tcpm_vals[] which is now in usec units. If we want to keep
dst metrics in msec units we can fix this only in tcpm_suck_dst.
Otherwise, similar attributes for dst metrics in ip/iproute.c
are needed.

Regards

--
Julian Anastasov <ja@ssi.bg>
