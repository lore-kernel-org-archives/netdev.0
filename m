From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] make TLLAO option for NA packets configurable
Date: Fri, 2 Oct 2009 10:53:51 -0700
Message-ID: <20091002105351.0fbde9c2@nehalam>
References: <20091001111450.221969cc@s6510>
	<20091001115611.0baa77b8@s6510>
	<20091001.123740.103898742.davem@davemloft.net>
	<200910020119.47320.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, cratiu@ixiacom.com,
	netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34996 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756561AbZJBRxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 13:53:53 -0400
In-Reply-To: <200910020119.47320.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Oct 2009 01:19:47 +0300
Octavian Purdila <opurdila@ixiacom.com> wrote:

> On Thursday 01 October 2009 22:37:40 you wrote:
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Thu, 1 Oct 2009 11:56:11 -0700
> > 
> > > On Thu, 1 Oct 2009 21:39:32 +0300
> > >
> > > Octavian Purdila <opurdila@ixiacom.com> wrote:
> > >> On Thursday 01 October 2009 21:14:50 you wrote:
> > >> > Probably this should be a per interface property rather than per
> > >> > namespace.
> > >>
> > >> In our case, where we have lots of interfaces active, it would be nice
> > >> to have the per namespace property as well.
> > >
> > > The ipv6 control infrastructure already has that option. If you changed
> > > your patch to use a per-interface control then there would be:
> > >
> > >   /proc/sys/net/ipv6/conf/all/force_tllao
> > 
> > Right, this would work a lot better.
> > 
> 
> Here is v3 which also updates Documentation/networking/ip-sysctl.txt.
> 
> Thanks,
> tavi
> 
> 

This is good although I would have shortened the name.


-- 
