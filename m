From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] IPv6 Updates for 2.6.21-rc1
Date: Wed, 21 Feb 2007 22:24:00 -0800 (PST)
Message-ID: <20070221.222400.69214713.davem@davemloft.net>
References: <20070222.131048.72079218.yoshfuji@linux-ipv6.org>
	<20070222.131354.132135579.yoshfuji@linux-ipv6.org>
	<20070222.133212.110548597.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	yasuyuki.kozakai@toshiba.co.ju
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51106
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751419AbXBVGYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 01:24:02 -0500
In-Reply-To: <20070222.133212.110548597.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 22 Feb 2007 13:32:12 +0900 (JST)

> Hello.
> 
> In article <20070222.131354.132135579.yoshfuji@linux-ipv6.org> (at Thu, 22 Feb 2007 13:13:54 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> 
> > In article <20070222.131048.72079218.yoshfuji@linux-ipv6.org> (at Thu, 22 Feb 2007 13:10:48 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> > 
> > > Here's several fixes on top of 2.6.21-rc1.
> > > Changesets are available on the
> > > 	2.6.21-rc1-inet6-20070222
> > > branch at
> > > 	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git>.
> > > 
> > > Regards,
> > 
> > Oops, sorry, I found a problem in exporting __ipv6_addr_type...
> > Just a moment, please...
> 
> Here's take 2; eliminated duplicate EXPORT_SYMBOL{,_GPL}.
> 
> Changesets are available on the
> 	2.6.21-rc1-inet6-20070222b
> branch at
> 	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git>.

File net/ipv6/addrconf_core.c is still missing even in this
updated pull, please fix this.

I ran:

git pull git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git 2.6.21-rc1-inet6-20070222b
