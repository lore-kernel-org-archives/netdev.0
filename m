From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 12/12] ixgbevf: Kconfig, Makefile and Documentation
Date: Thu, 10 Dec 2009 11:59:49 +1100
Message-ID: <20091210005949.GI4163@verge.net.au>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
 <20091208221652.28373.22254.stgit@localhost.localdomain>
 <20091208144136.dff6ce84.randy.dunlap@oracle.com>
 <43F901BD926A4E43B106BF17856F07558C0F4B7F@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59641 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbZLJA7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 19:59:43 -0500
Content-Disposition: inline
In-Reply-To: <43F901BD926A4E43B106BF17856F07558C0F4B7F@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2009 at 02:49:21PM -0800, Rose, Gregory V wrote:
> >-----Original Message-----
> >From: Randy Dunlap [mailto:randy.dunlap@oracle.com]
> >Sent: Tuesday, December 08, 2009 2:42 PM
> >To: Kirsher, Jeffrey T
> >Cc: netdev@vger.kernel.org; gospo@redhat.com; Rose, Gregory V
> >Subject: Re: [RFC PATCH 12/12] ixgbevf: Kconfig, Makefile and
> >Documentation
> >
> >> +The ixgbevf driver supports 82599-based virtual function devices that
> >can only
> >> +be activated on kernels with CONFIG_PCI_IOV enabled.
> >> +
> >> +The guest OS loading the ixgbevf driver must support MSI-X
> >interrupts.
> >
> >Hi,
> >
> >Could the Kconfig language express some of these requirements, or
> >am I confused between the host and the guest OS?
> [Rose, Gregory V] 
> 
> The guest OS must also support MSI-X interrupts.  It is a requirement of our VF device to use MSI-X.
> 
> >
> >
> >> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> >> index 0bbd5ae..a484415 100644
> >> --- a/drivers/net/Kconfig
> >> +++ b/drivers/net/Kconfig
> >> @@ -2614,6 +2614,27 @@ config IXGBE_DCB
> >>
> >>  	  If unsure, say N.
> >>
> >> +config IXGBEVF
> >> +       tristate "Intel(R) 82599 Virtual Function Ethernet support"
> >> +       depends on PCI
> >
> >	depends on PCI_IOV && PCI_MSI
> >??
> >
> [Rose, Gregory V] 
> 
> The guest does not need to have IOV support configured to use the VF device but it does need MSI-X.  We'll incorporate this suggested change.
> 
> Thanks for your comments.

The igbvf driver can also run on the host or indeed on a system
without virtualisation. Is the same true of the ixgbevf driver?

