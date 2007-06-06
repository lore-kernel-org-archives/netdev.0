From: wendy xiong <wendyx@us.ibm.com>
Subject: Re: [PATCH 3/5] NetXen: Add NETXEN prefix to macros
Date: Wed, 06 Jun 2007 13:33:57 -0500
Message-ID: <1181154837.25390.58.camel@wendyx.austin.ibm.com>
References: <200706011115.l51BFahX004752@dut39.unminc.com>
	 <4662E345.3070908@garzik.org>
	 <1181152364.25390.36.camel@wendyx.austin.ibm.com>
	 <20070606180546.GB23143@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mithlesh Thukral <mithlesh@netxen.com>, netdev@vger.kernel.org,
	amitkale@netxen.com, netxenproj@linsyssoft.com, rob@netxen.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:46157 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757099AbXFFSeC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 14:34:02 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l56HVPcM009589
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 13:31:25 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l56IXxtl528162
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 14:33:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l56IXwMg006419
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 14:33:59 -0400
In-Reply-To: <20070606180546.GB23143@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-06 at 14:05 -0400, Jeff Garzik wrote:
> On Wed, Jun 06, 2007 at 12:52:44PM -0500, wendy xiong wrote:
> > On Sun, 2007-06-03 at 11:50 -0400, Jeff Garzik wrote:
> > > Mithlesh Thukral wrote:
> > > > NetXen: Add NETXEN prefix to a macro
> > > > This patch will add the "NETXEN" prefix to "USER_START" macro.
> > > > 
> > > > Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
> > > > Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> > > > ---
> > > > 
> > > >  drivers/net/netxen/netxen_nic.h         |    4 ++--
> > > >  drivers/net/netxen/netxen_nic_ethtool.c |    2 +-
> > > >  drivers/net/netxen/netxen_nic_hw.c      |    4 ++--
> > > >  drivers/net/netxen/netxen_nic_init.c    |    4 ++--
> > > >  4 files changed, 7 insertions(+), 7 deletions(-)
> > > 
> > > Your patch description is useless.  Clearly we know -what- it does, 
> > > simply by reading the patch.
> > > 
> > > But it does not answer the simple question:  why?  why is this needed in 
> > > a bug fix Release Candidate series?
> > 
> > Hi Jeff,
> > 
> > When we backported netxen driver to 2.6.9 kernel on ppc, we saw the
> > compile errors for "USER_START". Because there is another definition for
> > USER_START which is used by arch/ppc64/mm/hash_utils.c and native.c.
> > 
> > So we like to add NETXEN before USER_START in netxen device driver, then
> > netxen driver can be compiled correctly in 2.6.9 kernel.
> > 
> > Let me know if you any question for this patch.
> 
> That answers my questions, but doesn't address the issue:  You need
> to regenerate the patch with the description improved as described.
> 
> The patch description is copied verbatim into the kernel changelog, and
> preserved verbatim for all eternity.  Four years from now, we need to be
> able to read the patch description and understand -why- the NETXEN_xxx
> prefix was added.  Simply stating that the NETXEN_xxx prefix was added
> is useless, as it is self-evident from reading the patch itself.
> 
> 	Jeff
> 
> 
> 
Jeff, 
Thanks.
We will re-generate the patch with correct issue title and description.

Thanks,
wendy

