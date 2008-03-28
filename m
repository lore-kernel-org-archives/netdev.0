From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1 of 5] IPv6: do not wrap around when the lifetime has
 expired
Date: Fri, 28 Mar 2008 12:06:22 +0900 (JST)
Message-ID: <20080328.120622.73826877.yoshfuji@linux-ipv6.org>
References: <dd125a7f86968371046d.1206305169@pirzuine>
	<20080328.032539.66693379.yoshfuji@linux-ipv6.org>
	<20080327193854.GC8574@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: benoit.boissinot@ens-lyon.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55385 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755571AbYC1DEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 23:04:52 -0400
In-Reply-To: <20080327193854.GC8574@ens-lyon.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080327193854.GC8574@ens-lyon.fr> (at Thu, 27 Mar 2008 20:38:54 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:

> On Fri, Mar 28, 2008 at 03:25:39AM +0900, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > In article <dd125a7f86968371046d.1206305169@pirzuine> (at Sun, 23 Mar 2008 21:46:09 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:
> > 
> > > IPv6: do not wrap around when the lifetime has expired
> > > 
> > > Instead of reporting overly large lifetimes to userspace,
> > > report a lifetime of 0 when a lifetime has expired.
> > > 
> > > Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
> > 
> > NAK.
> > 
> > (signed) lifetime < 0 means it has expired, but 0 does not mean
> > that the lifetime has expired, but it is being expired
> > (within 1 second).
> 
> It makes sense, so is the output of ip addr correct ?
> 
> inet6 2a01:5d8:58a0:ebfc:b5fb:88a3:27a5:ce96/64 scope global secondary deprecated dynamic
>    valid_lft 84064sec preferred_lft 4294964960sec
> 
> Can iproute2 be "fixed" ? or is it the expected output ?

Please fix iproute2.

--yoshfuji
