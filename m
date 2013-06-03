From: Joe Perches <joe@perches.com>
Subject: Re: [Patch net-next 1/2] ping: some cleanup for net/ipv4/ping.c
Date: Sun, 02 Jun 2013 22:59:07 -0700
Message-ID: <1370239147.2025.0.camel@joe-AO722>
References: <1370238959-32008-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38397 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751069Ab3FCF7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 01:59:21 -0400
In-Reply-To: <1370238959-32008-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 13:55 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
[]
> 3. fix "%pI6c" format
[]
> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
[]
> @@ -318,7 +318,7 @@ int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
>  			return -EINVAL;
>  
>  		pr_debug("ping_check_bind_addr(sk=%p,addr=%pI6c,port=%d)\n",
> -			 sk, addr->sin6_addr.s6_addr, ntohs(addr->sin6_port));
> +			 sk, &addr->sin6_addr, ntohs(addr->sin6_port));

why does this matter?
