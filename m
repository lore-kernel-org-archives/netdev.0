From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] netfilter: add netfilter ingress hook after
 handle_ing() under unique static key
Date: Thu, 14 May 2015 01:11:07 -0400 (EDT)
Message-ID: <20150514.011107.2098064573628886880.davem@davemloft.net>
References: <1431533978-26901-1-git-send-email-pablo@netfilter.org>
	<1431533978-26901-6-git-send-email-pablo@netfilter.org>
	<5553A7B9.7030203@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net,
	eric.dumazet@gmail.com, kaber@trash.net, ast@plumgrid.com
To: nicolas.dichtel@6wind.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <5553A7B9.7030203@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 13 May 2015 21:36:25 +0200

> Le 13/05/2015 18:19, Pablo Neira Ayuso a =E9crit :
> [snip]
>> --- /dev/null
>> +++ b/include/linux/netfilter_ingress.h
> [snip]
>> +static inline void nf_hook_ingress_init(struct net_device *dev)
>> +{
>> +        INIT_LIST_HEAD(&dev->nf_hooks_ingress);
> nit: this line is indented with spaces instead of a tab.

I took care of this when I applied Pablo's series.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
