From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: TSO packets automatic sizing
Date: Mon, 26 Aug 2013 17:47:08 -0700
Message-ID: <1377564428.8828.139.camel@edumazet-glaptop>
References: <1377304192.8828.43.camel@edumazet-glaptop>
	 <1377491162.8828.116.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Van Jacobson <vanj@google.com>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:59472 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340Ab3H0ArK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 20:47:10 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so4094137pdj.8
        for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 17:47:10 -0700 (PDT)
In-Reply-To: <1377491162.8828.116.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-25 at 21:26 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>

>  
> v2: Neal Cardwell reported a suspect deferring of last two segments on
> initial write of 10 MSS, I had to change tcp_tso_should_defer() to take
> into account tp->xmit_size_goal_segs 

Please do not apply, will send a v3, because srtt can be zero in some
occasions (divide by 0)
