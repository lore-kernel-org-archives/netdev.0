From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: TCP_NOSENT_LOWAT socket option
Date: Tue, 23 Jul 2013 08:28:07 -0700
Message-ID: <1374593287.3449.0.camel@edumazet-glaptop>
References: <1374520422.4990.33.camel@edumazet-glaptop>
	 <51ED9957.9070107@hp.com> <1374533052.4990.89.camel@edumazet-glaptop>
	 <51EDBB8B.2000805@hp.com> <1374538422.4990.99.camel@edumazet-glaptop>
	 <51EEA04F.8060708@hp.com>
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
Received: from mail-pa0-f54.google.com ([209.85.220.54]:56325 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757467Ab3GWP2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 11:28:10 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so8512074pab.13
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 08:28:10 -0700 (PDT)
In-Reply-To: <51EEA04F.8060708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 08:25 -0700, Rick Jones wrote:
> On 07/22/2013 05:13 PM, Eric Dumazet wrote:
> > On Mon, 2013-07-22 at 16:08 -0700, Rick Jones wrote:
> >> By the way, does this affect sendfile() or splice()?
> >
> > Sure : Patch intercepts sk_stream_memory_free() for all its callers.
> >
> > 10Gb link 'experiment with sendfile()' :
> 
> Why not the same 20 Gb (?) link you used with the other experiments?

Why not ? I have different kind of links ;)
