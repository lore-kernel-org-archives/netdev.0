From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Tue, 13 Feb 2007 19:10:58 -0500
Message-ID: <20070214001058.GC26818@gospo.rdu.redhat.com>
References: <20070209133802.01286bbb.akpm@linux-foundation.org> <20070213202905.GA26818@gospo.rdu.redhat.com> <200702132226.l1DMQS22009230@death.nxdomain.ibm.com> <20070213.143243.78711492.davem@davemloft.net> <20070213230803.GB26818@gospo.rdu.redhat.com> <200702132333.l1DNX022012433@death.nxdomain.ibm.com> <20070213155446.2f423782@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, lpiccilli@gelre.com.br,
	bugme-daemon@bugzilla.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60056 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932096AbXBNASu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 19:18:50 -0500
Content-Disposition: inline
In-Reply-To: <20070213155446.2f423782@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 03:54:46PM -0800, Stephen Hemminger wrote:
> > 
> > 	The problem with this is that it'll cause failures in the case
> > that some other unrelated entity holds rtnl ("x" will be performed
> > concurrently with whomever actually holds rtnl).
> > 
> 
> It is also a crap macro.

^^^ The 2 reasons why I never posted it for actual inclusion, but just
used it for testing....


