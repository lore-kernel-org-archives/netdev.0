From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 10/21] ipv6: fib: Add offload indication to
 routes
Date: Thu, 3 Aug 2017 10:39:47 -0600
Message-ID: <4092e040-4fcb-b13b-6de9-f77441c2bfb8@gmail.com>
References: <20170803112831.1831-1-jiri@resnulli.us>
 <20170803112831.1831-11-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        kafai@fb.com, hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:38277 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751791AbdHCQjv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:39:51 -0400
Received: by mail-pg0-f68.google.com with SMTP id 123so1951495pga.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 09:39:51 -0700 (PDT)
In-Reply-To: <20170803112831.1831-11-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/3/17 5:28 AM, Jiri Pirko wrote:
> diff --git a/include/uapi/linux/ipv6_route.h b/include/uapi/linux/ipv6_route.h
> index d496c02..33e2a57 100644
> --- a/include/uapi/linux/ipv6_route.h
> +++ b/include/uapi/linux/ipv6_route.h
> @@ -35,6 +35,7 @@
>  #define RTF_PREF(pref)	((pref) << 27)
>  #define RTF_PREF_MASK	0x18000000
>  
> +#define RTF_OFFLOAD	0x20000000	/* offloaded route		*/
>  #define RTF_PCPU	0x40000000	/* read-only: can not be set by user */
>  #define RTF_LOCAL	0x80000000

PCPU as a UAPI flag was a mistake; it is a flag internal to IPv6 stack
and really makes no sense to the user. The OFFLOAD should not follow
suit especially given the limited uapi bits left.
