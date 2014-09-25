From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/3] ipv4: rename ip_options_echo to
 __ip_options_echo()
Date: Thu, 25 Sep 2014 13:38:04 -0700
Message-ID: <1411677484.16953.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411676092-16196-1-git-send-email-edumazet@google.com>
	 <1411676092-16196-2-git-send-email-edumazet@google.com>
	 <1411677008.3460.7.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:62540 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbaIYUiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 16:38:06 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so10115015pde.20
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 13:38:05 -0700 (PDT)
In-Reply-To: <1411677008.3460.7.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 13:30 -0700, Joe Perches wrote:

> Unrelated:
> 
> I wonder how much effort, if any, should be made to convert
> struct sk_buff * to const struct sk_buff * where appropriate.
> 
> For instance:
> 
> This __ip_options_echo could use const struct sk_buff *skb
> if fib_compute_spec_dst was changed to const struct sk_buff *skb.

Well, this seems something certainly doable, as a follow up ;)
