From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] (2/4) support large number of network devices -- name
 hash
Date: Sat, 17 Jan 2004 11:22:44 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040117.112244.90941296.yoshfuji@linux-ipv6.org>
References: <20040116154652.04dd3324.shemminger@osdl.org>
	<20040116154814.7c7f31ac.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20040116154814.7c7f31ac.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040116154814.7c7f31ac.shemminger@osdl.org> (at Fri, 16 Jan 2004 15:48:14 -0800), Stephen Hemminger <shemminger@osdl.org> says:

> +	size_t len = min(strlen(name),(size_t)(IFNAMSIZ-1));

strnlen(name, IFNAMESIZ) ?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
