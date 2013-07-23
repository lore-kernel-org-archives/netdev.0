From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 net-next 2/2] tcp: TCP_NOTSENT_LOWAT socket option
Date: Tue, 23 Jul 2013 05:52:02 +0200
Message-ID: <20130723035202.GA32523@order.stressinduktion.org>
References: <1374550027.4990.141.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:33379 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559Ab3GWDwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 23:52:04 -0400
Content-Disposition: inline
In-Reply-To: <1374550027.4990.141.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 08:27:07PM -0700, Eric Dumazet wrote:
> Note this is not related to SO_SNDLOWAT (as SO_SNDLOWAT is
> defined as :
>  Specify the minimum number of bytes in the buffer until
>  the socket layer will pass the data to the protocol)

Oh, I had another understanding of SO_SNDLOWAT in my head: The minimum amount
of free write space in the socket buffer so that select/poll reports POLLOUT.

In my previous mail I was specifically referring to the optimization in
sk_stream_write_space() and not to the whole TCP_NOTSEND_LOWAT knob.

Thanks,

  Hannes
