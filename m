From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: TCP_NOSENT_LOWAT socket option
Date: Mon, 22 Jul 2013 17:40:13 -0700
Message-ID: <1374540013.4990.100.camel@edumazet-glaptop>
References: <1374520422.4990.33.camel@edumazet-glaptop>
	 <51ED9957.9070107@hp.com> <1374533052.4990.89.camel@edumazet-glaptop>
	 <51EDBB8B.2000805@hp.com> <1374538422.4990.99.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:40998 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589Ab3GWAkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 20:40:18 -0400
Received: by mail-oa0-f43.google.com with SMTP id i7so9774620oag.2
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 17:40:15 -0700 (PDT)
In-Reply-To: <1374538422.4990.99.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 17:13 -0700, Eric Dumazet wrote:

> 
>  Performance counter stats for './netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c':
> 
>            714,395 context-switches                                            

Hmm, actually I need to send a v3, because sk_stream_write_space() is
waking sockets too often.
