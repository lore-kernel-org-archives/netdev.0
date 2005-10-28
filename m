From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATH] [MCAST] IPv6: Fix algorithm to compute Querier's Query Interval
 and Maximum Response Delay
Date: Fri, 28 Oct 2005 10:18:47 -0700
Message-ID: <OF7FABC1EE.FDB8A0D4-ON882570A8.005EDBB4-882570A8.005F14D9@us.ibm.com>
References: <43624B98.6010405@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751650AbVJ1RSi@vger.kernel.org>
In-Reply-To: <43624B98.6010405@21cn.com>
To: Yan Zheng <yanzheng@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, I think you're correct.

Acked-by: David L Stevens <dlstevens@us.ibm.com>
> 
> Signed-off-by: Yan Zheng <yanzheng@21cn.com>
> 
> Index: net/ipv6/mcast.c
> ===================================================================
> --- linux-2.6.14/net/ipv6/mcast.c   2005-10-28 08:02:08.000000000 +0800
> +++ linux/net/ipv6/mcast.c   2005-10-28 23:41:18.000000000 +0800
> @@ -164,7 +164,7 @@
>  #define MLDV2_MASK(value, nb) ((nb)>=32 ? (value) : ((1<<(nb))-1) & 
(value))
>  #define MLDV2_EXP(thresh, nbmant, nbexp, value) \
>     ((value) < (thresh) ? (value) : \
> -   ((MLDV2_MASK(value, nbmant) | (1<<(nbmant+nbexp))) << \
> +   ((MLDV2_MASK(value, nbmant) | (1<<(nbmant))) << \
>     (MLDV2_MASK((value) >> (nbmant), nbexp) + (nbexp))))
> 
>  #define MLDV2_QQIC(value) MLDV2_EXP(0x80, 4, 3, value)
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
