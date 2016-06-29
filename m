From: Daniel Metz <dmetz@mytum.de>
Subject: Re: [PATCH net-next v3] tcp: use RFC6298 compliant TCP RTO
 calculation
Date: Wed, 29 Jun 2016 22:18:28 +0200
Message-ID: <d2568bd1-1722-fa7d-9870-279e2e5ef6fb@mytum.de>
References: <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
 <20160615180003.28970-1-dmetz@mytum.de>
 <20160617.113235.1099766688971255047.davem@davemloft.net>
 <CAK6E8=eQNkSyAujuqF9hiE1iFk03O4T6op_-g=y87+UQUrS4=Q@mail.gmail.com>
 <CAK6E8=cyrog=2UmVpwP3jzCtFAR9LxxtS+g01R42H9jk=_cZ2A@mail.gmail.com>
 <CAK6E8=dx0Yt7y2g6JBi4JWM5Z8ARQPSsAYioEOPS5DiGkTU1yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>
To: Yuchung Cheng <ycheng@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Daniel Metz <Daniel.Metz@rohde-schwarz.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.lrz.de ([129.187.255.136]:35080 "EHLO mailout2.lrz.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921AbcF2U0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 16:26:25 -0400
In-Reply-To: <CAK6E8=dx0Yt7y2g6JBi4JWM5Z8ARQPSsAYioEOPS5DiGkTU1yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>                                       B        D      R     Y
> ------------------------------------------------------------------------------
> mean TCPRecovLat      3s      -7%   +39% +38%
> mean TCPRecovLat2    52s     +1%   -11%  -11%

This is indeed very interesting and somewhat unexpected. Do you have any 
clue why Y is as bad as R and so much worse than B? By my understanding 
I would have expected Y to be similar to B. At least tests on the Mean 
Response Waiting Time of sender limited flows show hardly any difference 
to B (as expected).

Also, is a potential longer time in TCPRecovLat such a bad thing 
considering your information on HTTP response performance?
