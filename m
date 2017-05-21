From: David Ahern <dsahern@gmail.com>
Subject: Re: [net-next] net: ipv6: fix code style error and warning of ndisc.c
Date: Sun, 21 May 2017 10:16:18 -0600
Message-ID: <7824ba0b-9723-03f0-562a-4e41289381cf@gmail.com>
References: <1495253813-17168-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: yuan linyu <cugyly@163.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33334 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751583AbdEUQQ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 12:16:26 -0400
Received: by mail-pf0-f193.google.com with SMTP id f27so14796354pfe.0
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 09:16:26 -0700 (PDT)
In-Reply-To: <1495253813-17168-1-git-send-email-cugyly@163.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/17 10:16 PM, yuan linyu wrote:
> @@ -240,13 +240,15 @@ struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
>  					  "%s: duplicated ND6 option found: type=%d\n",
>  					  __func__, nd_opt->nd_opt_type);
>  			} else {
> -				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
> +				ndopts->nd_opt_array[nd_opt->nd_opt_type] =
> +					nd_opt;
>  			}
>  			break;
>  		case ND_OPT_PREFIX_INFO:
>  			ndopts->nd_opts_pi_end = nd_opt;
>  			if (!ndopts->nd_opt_array[nd_opt->nd_opt_type])
> -				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
> +				ndopts->nd_opt_array[nd_opt->nd_opt_type] =
> +					nd_opt;
>  			break;
>  #ifdef CONFIG_IPV6_ROUTE_INFO
>  		case ND_OPT_ROUTE_INFO:

This makes the code less readable. Readability needs to trump rigid
80-column coding style.


> @@ -512,7 +513,8 @@ void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
>  		in6_ifa_put(ifp);
>  	} else {
>  		if (ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
> -				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->srcprefs,
> +				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->
> +						srcprefs,

again here


I did not finish out this really long patch, but in general the
80-column rule can not be applied so rigidly.
