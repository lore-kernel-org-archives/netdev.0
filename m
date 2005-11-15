From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]IPv6: small fix for ipv6_dev_get_saddr(...)
Date: Tue, 15 Nov 2005 10:22:37 +0900 (JST)
Message-ID: <20051115.102237.101993116.yoshfuji@linux-ipv6.org>
References: <43786A16.9070100@21cn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932268AbVKOBWO@vger.kernel.org>
To: yanzheng@21cn.com, davem@davemloft.net
In-Reply-To: <43786A16.9070100@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <43786A16.9070100@21cn.com> (at Mon, 14 Nov 2005 18:42:30 +0800), Yan Zheng <yanzheng@21cn.com> says:

> The "score.rule++" doesn't make any sense for me. 
> According to codes above, I think it should be "hiscore.rule++;" .

Oops, you're right.

> Signed-off-by: Yan Zheng<yanzheng@21cn.com>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

>  			/* Rule 8: Use longest matching prefix */
> -			if (hiscore.rule < 8)
> +			if (hiscore.rule < 8) {
>  				hiscore.matchlen = ipv6_addr_diff(&ifa_result->addr, daddr);
> -			score.rule++;
> +				hiscore.rule++;
> +			}
>  			score.matchlen = ipv6_addr_diff(&ifa->addr, daddr);
>  			if (score.matchlen > hiscore.matchlen) {
>  				score.rule = 8;
> 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
