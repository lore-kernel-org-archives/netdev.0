From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] cnic: Fix mmap regression.
Date: Thu, 5 Jul 2012 14:59:46 -0700
Message-ID: <1341525586.7472.25.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1340998365-15753-1-git-send-email-mchan@broadcom.com>
 <20120629.153425.24594752441419170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3578 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752103Ab2GEWAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2012 18:00:21 -0400
In-Reply-To: <20120629.153425.24594752441419170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-29 at 15:34 -0700, David Miller wrote: 
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Fri, 29 Jun 2012 12:32:45 -0700
> 
> > commit 1f85d58cdf15354a7120fc9ccc9bb9c45b53af88
> >     cnic: Remove uio mem[0].
> > 
> > introduced a regression as older versions of userspace app still rely
> > on this mmap.  Restore the mmap functionality and get the base address
> > from pci_resource_start() as the nedev->base_addr has been deprecated for
> > PCI devices.
> > 
> > Update version to 2.5.12.
> > 
> > Signed-off-by: Michael Chan <mchan@broadocm.com>
> 
> I really couldn't believe what you guys were doing in the original
> commit, but I decided to let you do stupid things and find out the
> hard way that removing any user visible interface is basically
> impossible.
> 
> Applied, thanks.
> 

David, this patch plus the earlier commit are also needed for the net
tree because netdev->base_addr was removed there.  Can you apply these
directly to the net tree?  Or you want me to send you the equivalent
patches for net.  Thanks.
