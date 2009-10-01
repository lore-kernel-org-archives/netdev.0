From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] make TLLAO option for NA packets configurable
Date: Thu, 1 Oct 2009 11:56:11 -0700
Message-ID: <20091001115611.0baa77b8@s6510>
References: <200910011916.40908.cratiu@ixiacom.com>
	<200910012108.41071.cratiu@ixiacom.com>
	<20091001111450.221969cc@s6510>
	<200910012139.32070.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cosmin Ratiu <cratiu@ixiacom.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60182 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752952AbZJAS4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 14:56:08 -0400
In-Reply-To: <200910012139.32070.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Oct 2009 21:39:32 +0300
Octavian Purdila <opurdila@ixiacom.com> wrote:

> On Thursday 01 October 2009 21:14:50 you wrote:
> > 
> > Probably this should be a per interface property rather than per namespace.
> 
> In our case, where we have lots of interfaces active, it would be nice to have 
> the per namespace property as well.

The ipv6 control infrastructure already has that option. If you changed your
patch to use a per-interface control then there would be:

  /proc/sys/net/ipv6/conf/all/force_tllao
