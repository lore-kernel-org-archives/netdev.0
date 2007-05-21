From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] [TCP] tcp_probe: a trivial fix for mismatched number of
 printl arguments.
Date: Mon, 21 May 2007 09:00:53 -0700
Message-ID: <20070521090053.72d98316@freepuppy>
References: <11797335421143-git-send-email-sangtae.ha@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Sangtae Ha <sangtae.ha@gmail.com>
To: Sangtae Ha <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:55314 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755450AbXEUQGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 12:06:01 -0400
In-Reply-To: <11797335421143-git-send-email-sangtae.ha@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 May 2007 03:45:42 -0400
Sangtae Ha <sangtae.ha@gmail.com> wrote:

> Just a fix to correct the number of printl arguments. Now, srtt is logging correctly.
> 
> Signed-off-by: Sangtae Ha <sangtae.ha@gmail.com>
> ---
>  net/ipv4/tcp_probe.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
> index 3938d5d..1b72c55 100644
> --- a/net/ipv4/tcp_probe.c
> +++ b/net/ipv4/tcp_probe.c
> @@ -95,7 +95,7 @@ static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
>  	/* Only update if port matches */
>  	if ((port == 0 || ntohs(inet->dport) == port || ntohs(inet->sport) == port)
>  	    && (full || tp->snd_cwnd != tcpw.lastcwnd)) {
> -		printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %#x %#x %u %u %u\n",
> +		printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %#x %#x %u %u %u %u\n",
>  		       NIPQUAD(inet->saddr), ntohs(inet->sport),
>  		       NIPQUAD(inet->daddr), ntohs(inet->dport),
>  		       skb->len, tp->snd_nxt, tp->snd_una,

Looks good thanks

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
