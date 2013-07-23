From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: TCP_NOSENT_LOWAT socket option
Date: Tue, 23 Jul 2013 08:25:03 -0700
Message-ID: <51EEA04F.8060708@hp.com>
References: <1374520422.4990.33.camel@edumazet-glaptop> <51ED9957.9070107@hp.com> <1374533052.4990.89.camel@edumazet-glaptop> <51EDBB8B.2000805@hp.com> <1374538422.4990.99.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:1479 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757582Ab3GWPZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 11:25:06 -0400
In-Reply-To: <1374538422.4990.99.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2013 05:13 PM, Eric Dumazet wrote:
> On Mon, 2013-07-22 at 16:08 -0700, Rick Jones wrote:
>> By the way, does this affect sendfile() or splice()?
>
> Sure : Patch intercepts sk_stream_memory_free() for all its callers.
>
> 10Gb link 'experiment with sendfile()' :

Why not the same 20 Gb (?) link you used with the other experiments?

rick
