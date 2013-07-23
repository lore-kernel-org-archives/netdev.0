From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: TCP_NOSENT_LOWAT socket option
Date: Mon, 22 Jul 2013 18:33:23 -0700
Message-ID: <1374543203.4990.102.camel@edumazet-glaptop>
References: <1374520422.4990.33.camel@edumazet-glaptop>
	 <51ED9957.9070107@hp.com> <1374533052.4990.89.camel@edumazet-glaptop>
	 <51EDBB8B.2000805@hp.com> <1374538422.4990.99.camel@edumazet-glaptop>
	 <1374540013.4990.100.camel@edumazet-glaptop>
	 <20130723012002.GA30719@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:39145 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898Ab3GWBdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 21:33:31 -0400
Received: by mail-pa0-f49.google.com with SMTP id bi5so3654247pad.36
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 18:33:30 -0700 (PDT)
In-Reply-To: <20130723012002.GA30719@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 03:20 +0200, Hannes Frederic Sowa wrote:
> On Mon, Jul 22, 2013 at 05:40:13PM -0700, Eric Dumazet wrote:
> > On Mon, 2013-07-22 at 17:13 -0700, Eric Dumazet wrote:
> > 
> > > 
> > >  Performance counter stats for './netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c':
> > > 
> > >            714,395 context-switches                                            
> > 
> > Hmm, actually I need to send a v3, because sk_stream_write_space() is
> > waking sockets too often.
> 
> Do you implement SO_SNDLOWAT? :)

Not exactly.

This is going to be a FAQ I guess ;)
