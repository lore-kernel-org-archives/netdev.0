From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Fri, 25 Apr 2008 16:24:17 +0900 (JST)
Message-ID: <20080425.162417.25756786.yoshfuji@linux-ipv6.org>
References: <20080424.234748.53723057.davem@davemloft.net>
	<20080425.155922.32198314.yoshfuji@linux-ipv6.org>
	<20080425.000418.108840147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33541 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbYDYHYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:24:18 -0400
In-Reply-To: <20080425.000418.108840147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080425.000418.108840147.davem@davemloft.net> (at Fri, 25 Apr 2008 00:04:18 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Fri, 25 Apr 2008 15:59:22 +0900 (JST)
> 
> > In article <20080424.234748.53723057.davem@davemloft.net> (at Thu, 24 Apr 2008 23:47:48 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> > 
> > > From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> > > Date: Fri, 25 Apr 2008 15:37:33 +0900 (JST)
> > > 
> > > > In article <20080424.233159.06679047.davem@davemloft.net> (at Thu, 24 Apr 2008 23:31:59 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> > > > 
> > > > > 1) Use copy_in_user() as that's the proper interaface to copy within
> > > > >    userspace in COMPAT code.
> > > > 
> > > > So, don't we care increase of copy operation with it?
> > > 
> > > I think for now it's an OK tradeoff, but yes it does increase
> > > copies.  But then again, many compat layer handlers do.
> > 
> > And in IPv4, group_XXX{} handlers are even wrappers for ip_mreqXXX{}
> > handlers so we we have another copy...
> 
> It is always possible to simplify things and make them more efficient.
> And we should always do that.
> 
> The priority at the moment should be the simplist bug fix.

Okay I will pend them for net-2.6.27.

--yoshfuji
