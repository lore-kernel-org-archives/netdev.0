From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: Sat, 24 Jul 2004 21:33:23 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040724.213323.61478122.yoshfuji@linux-ipv6.org>
References: <20040723135945.7f50b02c.davem@redhat.com>
	<1090630154.1134.6.camel@jzny.localdomain>
	<1090675993.1161.11.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, shemminger@osdl.org, arekm@pld-linux.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1090675993.1161.11.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <1090675993.1161.11.camel@jzny.localdomain> (at 24 Jul 2004 09:33:52 -0400), jamal <hadi@cyberus.ca> says:

> Makes the performance counters a separate TLV -  a little bit of a pain,
> but acceptable given its optional.
> Compiles but hasnt been tested; user space code will have to change.

basically, looks fine.

1. is it okay to use unsigned long?
   I'd rather prefer __u32 or __u64.

2. please use kcnts[0] instead of kcnts[] because
   user probably want to do sizeof(struct tc_u32_pcnt)

> I dont want to touch the policer for now.

hmm. :-P

Thanks.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
