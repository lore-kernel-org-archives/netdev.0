From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: Fri, 10 Sep 2004 23:00:38 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910.230038.322907649.yoshfuji@linux-ipv6.org>
References: <20040910133637.GA20088@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20040910133637.GA20088@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040910133637.GA20088@postel.suug.ch> (at Fri, 10 Sep 2004 15:36:37 +0200), Thomas Graf <tgraf@suug.ch> says:

> Allows changing of device name via rtnetlink. Last bit needed to do full
> link configuration via rtnetlink.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
:
> +		if (ida[IFLA_IFNAME - 1]->rta_len > RTA_LENGTH(IFNAMSIZ))
> +			goto out;

Please use sizeof(ifname) instead.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
