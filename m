From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] IPv6 Updates for 2.6.21-rc1
Date: Thu, 22 Feb 2007 16:48:52 +0900 (JST)
Message-ID: <20070222.164852.47947702.yoshfuji@linux-ipv6.org>
References: <20070222.160515.73902189.yoshfuji@linux-ipv6.org>
	<20070221.232306.51841241.davem@davemloft.net>
	<20070221.232735.107942036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	yasuyuki.kozakai@toshiba.co.jp, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:57076 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945941AbXBVHsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 02:48:45 -0500
In-Reply-To: <20070221.232735.107942036.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070221.232735.107942036.davem@davemloft.net> (at Wed, 21 Feb 2007 23:27:35 -0800 (PST)), David Miller <davem@davemloft.net> says:

> From: David Miller <davem@davemloft.net>
> Date: Wed, 21 Feb 2007 23:23:06 -0800 (PST)
> 
> > From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> > Date: Thu, 22 Feb 2007 16:05:15 +0900 (JST)
> > 
> > > ....fixed.  Please pull from new 2.6.21-rc1-inet6-20070222c branch:
> > >   git pull git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git 2.6.21-rc1-inet6-20070222c
> > 
> > Thank you, it looks much better now.
> 
> I spoke too soon :-/  I guess you guys really do not like testing
> ipv6 built modular, but it is what %99.9999 of people do.
> 
>   Building modules, stage 2.
>   MODPOST 137 modules
> WARNING: "__ipv6_addr_type" [net/ipv6/ipv6.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2

My bad... I once moved that to net/ipv6/addrconf_core.c...
sigh...

I think it's time to distribute all EXPORT_SYMBOL 
things in ipv6_syms.c to each file which each symbol is
actually defined.  Don't you think so?

--yoshfuji
