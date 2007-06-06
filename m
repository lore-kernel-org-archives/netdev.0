From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/5] NetXen: Add NETXEN prefix to macros
Date: Wed, 6 Jun 2007 14:05:46 -0400
Message-ID: <20070606180546.GB23143@havoc.gtf.org>
References: <200706011115.l51BFahX004752@dut39.unminc.com> <4662E345.3070908@garzik.org> <1181152364.25390.36.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mithlesh Thukral <mithlesh@netxen.com>, netdev@vger.kernel.org,
	amitkale@netxen.com, netxenproj@linsyssoft.com, rob@netxen.com
To: wendy xiong <wendyx@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:49609 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759459AbXFFSFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 14:05:48 -0400
Content-Disposition: inline
In-Reply-To: <1181152364.25390.36.camel@wendyx.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 06, 2007 at 12:52:44PM -0500, wendy xiong wrote:
> On Sun, 2007-06-03 at 11:50 -0400, Jeff Garzik wrote:
> > Mithlesh Thukral wrote:
> > > NetXen: Add NETXEN prefix to a macro
> > > This patch will add the "NETXEN" prefix to "USER_START" macro.
> > > 
> > > Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
> > > Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> > > ---
> > > 
> > >  drivers/net/netxen/netxen_nic.h         |    4 ++--
> > >  drivers/net/netxen/netxen_nic_ethtool.c |    2 +-
> > >  drivers/net/netxen/netxen_nic_hw.c      |    4 ++--
> > >  drivers/net/netxen/netxen_nic_init.c    |    4 ++--
> > >  4 files changed, 7 insertions(+), 7 deletions(-)
> > 
> > Your patch description is useless.  Clearly we know -what- it does, 
> > simply by reading the patch.
> > 
> > But it does not answer the simple question:  why?  why is this needed in 
> > a bug fix Release Candidate series?
> 
> Hi Jeff,
> 
> When we backported netxen driver to 2.6.9 kernel on ppc, we saw the
> compile errors for "USER_START". Because there is another definition for
> USER_START which is used by arch/ppc64/mm/hash_utils.c and native.c.
> 
> So we like to add NETXEN before USER_START in netxen device driver, then
> netxen driver can be compiled correctly in 2.6.9 kernel.
> 
> Let me know if you any question for this patch.

That answers my questions, but doesn't address the issue:  You need
to regenerate the patch with the description improved as described.

The patch description is copied verbatim into the kernel changelog, and
preserved verbatim for all eternity.  Four years from now, we need to be
able to read the patch description and understand -why- the NETXEN_xxx
prefix was added.  Simply stating that the NETXEN_xxx prefix was added
is useless, as it is self-evident from reading the patch itself.

	Jeff



