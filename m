From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]dump interface IPv6 multicast/anycast addresses through
 netlink
Date: Fri, 19 Mar 2004 15:55:36 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040319.155536.20327066.yoshfuji@linux-ipv6.org>
References: <200403171130.30282.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, xma@us.ibm.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mashirle@us.ibm.com
In-Reply-To: <200403171130.30282.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200403171130.30282.mashirle@us.ibm.com> (at Wed, 17 Mar 2004 11:30:30 -0800), Shirley Ma <mashirle@us.ibm.com> says:

> @@ -339,6 +345,7 @@
>  	IFA_LOCAL,
>  	IFA_LABEL,
>  	IFA_BROADCAST,
> +	IFA_MULTICAST,
>  	IFA_ANYCAST,
>  	IFA_CACHEINFO
>  };

Please, please do not change IFA_XXX values.
You should put "IFA_MULTICAST" next to IFA_CACHEINFO.

--yoshfuji
