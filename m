From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:appletalk:ddp:fixed coding style issue again
 relating to
Date: Tue, 07 Aug 2012 14:46:09 -0700 (PDT)
Message-ID: <20120807.144609.956779270587698041.davem@davemloft.net>
References: <1344348020-4966-1-git-send-email-ahiliation@yahoo.co.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ahiliation@yahoo.co.in
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344348020-4966-1-git-send-email-ahiliation@yahoo.co.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeffrin Jose <ahiliation@yahoo.co.in>
Date: Tue,  7 Aug 2012 19:30:20 +0530

> Fixed coding style issue relating to indentation in
> net/appletalk/ddp.c found by checkpatch.pl tool
> 
> Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>

Please just stop trying to fix this code up, it's noise and you
keep making mistakes.

>  	case TIOCOUTQ: {
> -			long amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
> +		long amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
>  
> -			if (amount < 0)
> -				amount = 0;
> -			rc = put_user(amount, (int __user *)argp);
> -			break;
> +		if (amount < 0)
> +			amount = 0;
> +		rc = put_user(amount, (int __user *)argp);
> +		break;
>  		}

This time you didn't adjust the closing brace, as needed.

I'm not applying this and I seriously discourage you from pursing this
further, it's better you spend your time learning how the kernel works
rather than suffering through this coding style cleanup business.

Thanks.
