From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] netfilter: remove synchronize_net() calls
 in ip_queue/ip6_queue
Date: Wed, 04 Nov 2009 21:15:20 +0100
Message-ID: <4AF1E0D8.1020607@trash.net>
References: <4AF1DA57.8080202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4AF1DA57.8080202@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> nf_unregister_queue_handlers() already does a synchronize_rcu()
> call, we dont need to do it again in callers.

Applied, thanks Eric.
