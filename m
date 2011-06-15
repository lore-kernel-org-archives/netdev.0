From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [Xen-devel] Re: [PATCH 2/9] xen: convert to 64 bit stats
 interface
Date: Wed, 15 Jun 2011 09:38:12 +0100
Message-ID: <1308127092.17937.118.camel@zakaz.uk.xensource.com>
References: <20110609005356.160260858@vyatta.com>
	 <20110609005417.385577995@vyatta.com>
	 <1307584605.22348.527.camel@localhost>
	 <20110614210756.GA22304@dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	"David S. Miller" <davem@davemloft.net>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:64014 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059Ab1FOIiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 04:38:14 -0400
In-Reply-To: <20110614210756.GA22304@dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-14 at 22:07 +0100, Konrad Rzeszutek Wilk wrote:
> On Thu, Jun 09, 2011 at 02:56:45AM +0100, Ben Hutchings wrote:
> > On Wed, 2011-06-08 at 17:53 -0700, Stephen Hemminger wrote:
> > > Convert xen driver to 64 bit statistics interface.
> > > This driver was already counting packet per queue in a 64 bit value so not
> > > a huge change.
> > [...]
> > 
> > I think this driver will need to use u64_stats_sync.
> 
> Ian?

I'll defer to Ben on this, but the case for needing u64_stats_sync for
64 bit values seems reasonable to me.

Ian.

