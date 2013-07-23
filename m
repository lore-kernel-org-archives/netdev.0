From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] tcp: TCP_NOSENT_LOWAT socket option
Date: Tue, 23 Jul 2013 03:20:02 +0200
Message-ID: <20130723012002.GA30719@order.stressinduktion.org>
References: <1374520422.4990.33.camel@edumazet-glaptop> <51ED9957.9070107@hp.com> <1374533052.4990.89.camel@edumazet-glaptop> <51EDBB8B.2000805@hp.com> <1374538422.4990.99.camel@edumazet-glaptop> <1374540013.4990.100.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:33213 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898Ab3GWBUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 21:20:04 -0400
Content-Disposition: inline
In-Reply-To: <1374540013.4990.100.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 05:40:13PM -0700, Eric Dumazet wrote:
> On Mon, 2013-07-22 at 17:13 -0700, Eric Dumazet wrote:
> 
> > 
> >  Performance counter stats for './netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c':
> > 
> >            714,395 context-switches                                            
> 
> Hmm, actually I need to send a v3, because sk_stream_write_space() is
> waking sockets too often.

Do you implement SO_SNDLOWAT? :)

Greetings,

  Hannes
