From: YOSHIFUJI Hideaki <yoshfuji@st-paulia.net>
Subject: Re: [PATCH 1/1][TCP]: break missing at end of switch statement
Date: Mon, 01 Oct 2007 22:20:59 +0900 (JST)
Message-ID: <20071001.222059.11266966.yoshfuji@st-paulia.net>
References: <200710011332.43657@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from sapphire.linux-ipv6.org ([203.178.140.14]:52773 "EHLO
	sapphire.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbXJANwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:52:54 -0400
In-Reply-To: <200710011332.43657@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200710011332.43657@strip-the-willow> (at Mon, 1 Oct 2007 13:32:43 +0100), Gerrit Renker <gerrit@erg.abdn.ac.uk> says:

> [TCP]: break missing at end of switch statement
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3129,6 +3129,7 @@ static void tcp_reset(struct sock *sk)
>  			return;
>  		default:
>  			sk->sk_err = ECONNRESET;
> +			break;
>  	}
>  
>  	if (!sock_flag(sk, SOCK_DEAD))

NAK; it is not required at all.

--yoshfuji
