From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH]small fix for __ipv6_addr_type(...)
Date: Tue, 15 Nov 2005 17:20:50 -0500
Message-ID: <437A5F42.3080100@hp.com>
References: <4376F2CE.4050003@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965043AbVKOWUy@vger.kernel.org>
To: Yan Zheng <yanzheng@21cn.com>
In-Reply-To: <4376F2CE.4050003@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No, according to RFC 4007, loopback is considered a link-local
address.

-vlad

Yan Zheng wrote:
> Hi.
> 
> I think the scope for loopback address should be node local.
> 
> Regards
> 
> Signed-off-by: Yan Zheng <yanzheng@21cn.com>
> 
> ========================================================================
> --- linux-2.6.15-rc1/net/ipv6/addrconf.c    2005-11-13
> 12:23:06.000000000 +0800
> +++ linux/net/ipv6/addrconf.c    2005-11-13 15:50:03.000000000 +0800
> @@ -249,7 +249,7 @@ int __ipv6_addr_type(const struct in6_ad
> 
>             if (addr->s6_addr32[3] == htonl(0x00000001))
>                 return (IPV6_ADDR_LOOPBACK | IPV6_ADDR_UNICAST |
> -                   
> IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL));    /* addr-select 3.4 */
> +                   
> IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_NODELOCAL));    /* addr-select 3.4 */
> 
>             return (IPV6_ADDR_COMPATv4 | IPV6_ADDR_UNICAST |
>                 IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));    /*
> addr-select 3.3 */
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
