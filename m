From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 22:49:20 +0200
Message-ID: <20100823204920.GC5896@nuttenaction>
References: <1282590037-18566-1-git-send-email-hagen@jauu.net>
 <1282596243.2378.327.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:59653 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753222Ab0HWUtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 16:49:36 -0400
Content-Disposition: inline
In-Reply-To: <1282596243.2378.327.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2010-08-23 22:44:03 [+0200]:

>>  static inline void inet_csk_delack_init(struct sock *sk)
>>  {
>>  	memset(&inet_csk(sk)->icsk_ack, 0, sizeof(inet_csk(sk)->icsk_ack));
>> +	inet_csk(sk)->icsk_ack.pingpong = sysctl_tcp_quickack ? 0 : 1;
>
>What about dccp using this function ?

I will check this and re-spin the patch if necessary. Thank you Eric, I missed
DCCP.

>So here is a new undocumented setting ? hint hint...
>
>I thought setsockopt(TCP_QUICKACK) was already available for this
>optimization ?

... and it is still available. ;-) See my other post answering Stephen's email.

Hagen
