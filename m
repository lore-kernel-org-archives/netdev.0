From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: ip6_ra_control
Date: Fri, 06 Dec 2002 10:57:15 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021206.105715.03276611.yoshfuji@linux-ipv6.org>
References: <001801c29cc6$25688660$6c06a8c0@zhengjp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: zjp@iscas.ac.cn
In-Reply-To: <001801c29cc6$25688660$6c06a8c0@zhengjp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <001801c29cc6$25688660$6c06a8c0@zhengjp> (at Fri, 6 Dec 2002 09:23:55 +0800), "Zheng Jianping" <zjp@iscas.ac.cn> says:

> What's this function mean, and when&how to call it?
> int ip6_ra_control(struct sock *sk, int sel, void (*destructor)(struct sock *))

setsockopt(sock, IPPPROTO_IPV6, IPV6_ROUTER_ALERT, &i, sizeof(i))
to receive packet with Router Alert Hop-by-Hop option on routers.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
