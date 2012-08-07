From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net:appletalk:ddp:fixed coding style issue again relating to
Date: Tue, 07 Aug 2012 07:25:07 -0700
Message-ID: <874noeeq4c.fsf@xmission.com>
References: <1344348020-4966-1-git-send-email-ahiliation@yahoo.co.in>
Mime-Version: 1.0
Content-Type: text/plain
Cc: acme@ghostprotocols.net, davem@davemloft.net,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeffrin Jose <ahiliation@yahoo.co.in>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344348020-4966-1-git-send-email-ahiliation@yahoo.co.in>
	(Jeffrin Jose's message of "Tue, 7 Aug 2012 19:30:20 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeffrin Jose <ahiliation@yahoo.co.in> writes:

>  	case TIOCINQ: {
>  			/*
>  			 * These two are safe on a single CPU system as only
>  			 * user tasks fiddle here
>  			 */
> -			struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
> -			long amount = 0;
> +		struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
> +		long amount = 0;
>  
> -			if (skb)
> -				amount = skb->len - sizeof(struct ddpehdr);
> +		if (skb)
> +			amount = skb->len - sizeof(struct ddpehdr);
>  			rc = put_user(amount, (int __user *)argp);
>  			break;
>  		}

Is putting "rc = put_user(amount, (int __user *)argp);" on the same
indentation level as "amount = skb->len - sizeof(struct ddpehdr);"
really what you want to do?

Eric
