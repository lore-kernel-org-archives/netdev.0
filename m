From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] NETDEBUG network triggerable messages in IPv6
Date: Sat, 10 Apr 2004 01:00:51 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040410.010051.129465789.yoshfuji@linux-ipv6.org>
References: <20040409174847.2f0b7e77.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20040409174847.2f0b7e77.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040409174847.2f0b7e77.ak@suse.de> (at Fri, 9 Apr 2004 17:48:47 +0200), Andi Kleen <ak@suse.de> says:

> This wraps all potentially network triggerable printks in IPv6 with NETDEBUG.

I really do NOT like this. Please, please do not do this.

>  		case ICMP_SR_FAILED:
> -			if (net_ratelimit())
> +			NETDEBUG(if (net_ratelimit())
>  				printk(KERN_INFO "ICMP: %u.%u.%u.%u: Source "
>  						 "Route Failed.\n",
> -				       NIPQUAD(iph->daddr));
> +				       NIPQUAD(iph->daddr)));

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
