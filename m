From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next 1/8] pci: Add flag indicating device has been
 assigned by KVM [and Xen]
Date: Mon, 26 Sep 2011 10:01:36 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019C51941D@orsmsx508.amr.corp.intel.com>
References: <43F901BD926A4E43B106BF17856F0755019C518C47@orsmsx508.amr.corp.intel.com>
 <1316792710.2182.124.camel@jtkirshe-mobl>
 <20110923164326.GA23363@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C518D57@orsmsx508.amr.corp.intel.com>
 <20110923180025.GA6251@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C518E23@orsmsx508.amr.corp.intel.com>
 <20110923190537.GA18850@phenom.oracle.com>
 <1316839300.2182.134.camel@jtkirshe-mobl>
 <20110926162552.GA4175@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C5193AF@orsmsx508.amr.corp.intel.com>
 <20110926164238.GA4667@phenom.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Ian Campbell <ijc@hellion.org.uk>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16495 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198Ab1IZRBj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 13:01:39 -0400
In-Reply-To: <20110926164238.GA4667@phenom.oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Konrad Rzeszutek Wilk [mailto:konrad.wilk@oracle.com]
> Sent: Monday, September 26, 2011 9:43 AM
> To: Rose, Gregory V
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; Ian Campbell; Jesse Barnes;
> netdev@vger.kernel.org; gospo@redhat.com; linux-pci@vger.kernel.org
> Subject: Re: [net-next 1/8] pci: Add flag indicating device has been
> assigned by KVM [and Xen]
> 
> > > Any plans to support bnx4 and igb with this feature?
> >
> > I'm updating the igb driver to support this feature right now.  I would
> hesitate to get into other drivers and muck with them because the changes
> to support this feature are not trivial and also involve policy decisions
> that I'd prefer to leave up to the folks who maintain those drivers.  Plus
> I have no other vendor hardware available to test the changes.
> >
> 
> Sounds fair. Did you CC them?

I'll grep through the drivers and find who calls pci_disable_sriov() and send the respective driver maintainers a notification letting them know of the patches.

> 
> > > Any ETA?
> >
> > I should have the igb driver work done in the next week or so.
> 
> Ok, please CC me on the code when you post it.

Will do.

- Greg
