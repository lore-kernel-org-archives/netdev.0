From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] tcp: fix tcp_release_cb() to dispatch via address
 family for mtu_reduced()
Date: Thu, 14 Aug 2014 14:40:31 -0700 (PDT)
Message-ID: <20140814.144031.2123782488887755823.davem@redhat.com>
References: <1408034405-30596-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4948 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932068AbaHNVkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 17:40:33 -0400
In-Reply-To: <1408034405-30596-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 14 Aug 2014 12:40:05 -0400

> Make sure we use the correct address-family-specific function for
> handling MTU reductions from within tcp_release_cb().
> 
> Previously AF_INET6 sockets were incorrectly always using the IPv6
> code path when sometimes they were handling IPv4 traffic and thus had
> an IPv4 dst.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Diagnosed-by: Willem de Bruijn <willemb@google.com>
> Fixes: 563d34d057862 ("tcp: dont drop MTU reduction indications")

Applied and queued up for -stable.
