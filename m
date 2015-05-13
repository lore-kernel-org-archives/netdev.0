From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 5/5] netfilter: add netfilter ingress hook after handle_ing()
 under unique static key
Date: Wed, 13 May 2015 21:36:25 +0200
Message-ID: <5553A7B9.7030203@6wind.com>
References: <1431533978-26901-1-git-send-email-pablo@netfilter.org> <1431533978-26901-6-git-send-email-pablo@netfilter.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, kaber@trash.net,
	ast@plumgrid.com
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431533978-26901-6-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 13/05/2015 18:19, Pablo Neira Ayuso a =C3=A9crit :
[snip]
> --- /dev/null
> +++ b/include/linux/netfilter_ingress.h
[snip]
> +static inline void nf_hook_ingress_init(struct net_device *dev)
> +{
> +        INIT_LIST_HEAD(&dev->nf_hooks_ingress);
nit: this line is indented with spaces instead of a tab.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
