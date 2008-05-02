From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] unify the macro get_u16 in the file tulip.h
Date: Thu, 1 May 2008 21:52:18 -0600
Message-ID: <20080502035218.GC10542@colo.lackof.org>
References: <93C271C5-550E-406B-AE43-C83419EA0BC6@gmail.com> <20080501001522.GB10542@colo.lackof.org> <1209602629.8601.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	gao changli <xiaosuo@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:33576 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755201AbYEBDw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2008 23:52:29 -0400
Content-Disposition: inline
In-Reply-To: <1209602629.8601.6.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 30, 2008 at 05:43:49PM -0700, Joe Perches wrote:
> On Wed, 2008-04-30 at 18:15 -0600, Grant Grundler wrote:
> > On Thu, May 01, 2008 at 01:34:38AM +0800, gao changli wrote:
> > > Unify the macro get_u16 with le16_to_cpu.
> > > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> > Acked-by: Grant Grundler <grundler@parisc-linux.org>
> > please apply.  Depends on other patches that define le16_to_cpu().
> 
> Wouldn't it be better to remove get_u16 altogether
> and use le16_to_cpu or __le16_to_cpup directly?

Yes, it would be. But Changli's patch was an improvement in reducing
nested macros across several drivers and he was trying to minimize
churn with that patchset.

Can you please submit a patch that removes get_u16()?

thanks,
grant
