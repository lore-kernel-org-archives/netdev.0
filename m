From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Fri, 25 Apr 2008 00:04:18 -0700 (PDT)
Message-ID: <20080425.000418.108840147.davem@davemloft.net>
References: <20080425.153733.98184095.yoshfuji@linux-ipv6.org>
	<20080424.234748.53723057.davem@davemloft.net>
	<20080425.155922.32198314.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35849
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751253AbYDYHES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:04:18 -0400
In-Reply-To: <20080425.155922.32198314.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Fri, 25 Apr 2008 15:59:22 +0900 (JST)

> In article <20080424.234748.53723057.davem@davemloft.net> (at Thu, 24 Apr 2008 23:47:48 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> > Date: Fri, 25 Apr 2008 15:37:33 +0900 (JST)
> > 
> > > In article <20080424.233159.06679047.davem@davemloft.net> (at Thu, 24 Apr 2008 23:31:59 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> > > 
> > > > 1) Use copy_in_user() as that's the proper interaface to copy within
> > > >    userspace in COMPAT code.
> > > 
> > > So, don't we care increase of copy operation with it?
> > 
> > I think for now it's an OK tradeoff, but yes it does increase
> > copies.  But then again, many compat layer handlers do.
> 
> And in IPv4, group_XXX{} handlers are even wrappers for ip_mreqXXX{}
> handlers so we we have another copy...

It is always possible to simplify things and make them more efficient.
And we should always do that.

The priority at the moment should be the simplist bug fix.
