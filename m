From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: (usagi-users 03645) Re: How to retrieve kernel's IPv6 routing cache table?
Date: Thu, 30 Mar 2006 23:58:38 +0900 (JST)
Message-ID: <20060330.235838.30940800.yoshfuji@linux-ipv6.org>
References: <442BED92.4030007@bieringer.de>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <usagi-users-admin@linux-ipv6.org>
To: pb@bieringer.de
In-Reply-To: <442BED92.4030007@bieringer.de>
Resent-Message-Id: <20060330.235925.02236800.yoshfuji@linux-ipv6.org>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Hello.

In article <442BED92.4030007@bieringer.de> (at Thu, 30 Mar 2006 16:39:14 +0200), Peter Bieringer <pb@bieringer.de> says:

> IPv6:
> # ip -6 route show table cache
> ff02::1 via ff02::1 dev eth0  metric 0
>     cache  mtu 1280 advmss 1220 metric 10 4294967295
> ff02::1:ffea:7781 via ff02::1:ffea:7781 dev eth0  metric 0
>     cache  mtu 1280 advmss 1220 metric 10 4294967295
> 
> That's all? I would expect similar to IPv4 like:

No surprise, that's all.

> # ip -4 route show table cache
> local 127.0.0.1 from 127.0.0.1 dev lo
>     cache <local>  mtu 16436 advmss 16396 metric 10 64
:

We don't have "cache" route unless it is link-local, or
you got e.g. "too big" or "redirect", so far.

--yoshfuji
