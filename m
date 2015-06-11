From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/5] tcp: defer shinfo->gso_size|type settings
Date: Thu, 11 Jun 2015 16:57:40 -0700
Message-ID: <1434067060.27504.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434039319-31309-1-git-send-email-edumazet@google.com>
	 <20150611.164502.578119775073363894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ncardwell@google.com,
	ycheng@google.com, edumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36695 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbbFKX5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 19:57:43 -0400
Received: by igbpi8 with SMTP id pi8so1121840igb.1
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 16:57:42 -0700 (PDT)
In-Reply-To: <20150611.164502.578119775073363894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-06-11 at 16:45 -0700, David Miller wrote:

> Series applied, however long term I worry that using a u16 will not
> work with TSO'd ipv6 jumbograms.

Well, this would be very long term, as we currently limit GSO/TSO
packets to less than 64KB anyway (tcp_xmit_size_goal())

new_size_goal = sk->sk_gso_max_size - 1 - MAX_TCP_HEADER;

Thanks
