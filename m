From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6 NET] Catch wrong RTATTR_MAX with BUG()
Date: Fri, 10 Sep 2004 02:24:28 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910.022428.58971457.yoshfuji@linux-ipv6.org>
References: <20040909164346.GA18994@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20040909164346.GA18994@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040909164346.GA18994@postel.suug.ch> (at Thu, 9 Sep 2004 18:43:46 +0200), Thomas Graf <tgraf@suug.ch> says:

>  	kind = type&3;
>  
> +	if (RTATTR_MAX < rta_max[sz_idx])
> +		BUG();
> +

Something like:
	if (rta_max[sz_idx] > RTATTR_MAX)
		goto err_inval;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
