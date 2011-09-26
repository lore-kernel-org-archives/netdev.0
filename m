From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next 1/8] pci: Add flag indicating device has been
 assigned by KVM [and Xen]
Date: Mon, 26 Sep 2011 09:31:08 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019C5193AF@orsmsx508.amr.corp.intel.com>
References: <43F901BD926A4E43B106BF17856F0755019C518C0E@orsmsx508.amr.corp.intel.com>
 <1316790220.23371.105.camel@zakaz.uk.xensource.com>
 <43F901BD926A4E43B106BF17856F0755019C518C47@orsmsx508.amr.corp.intel.com>
 <1316792710.2182.124.camel@jtkirshe-mobl>
 <20110923164326.GA23363@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C518D57@orsmsx508.amr.corp.intel.com>
 <20110923180025.GA6251@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C518E23@orsmsx508.amr.corp.intel.com>
 <20110923190537.GA18850@phenom.oracle.com>
 <1316839300.2182.134.camel@jtkirshe-mobl>
 <20110926162552.GA4175@phenom.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <ijc@hellion.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20110926162552.GA4175@phenom.oracle.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Konrad Rzeszutek Wilk [mailto:konrad.wilk@oracle.com]
> Sent: Monday, September 26, 2011 9:26 AM
> To: Kirsher, Jeffrey T; davem@davemloft.net
> Cc: Rose, Gregory V; Ian Campbell; davem@davemloft.net; Jesse Barnes;
> netdev@vger.kernel.org; gospo@redhat.com; linux-pci@vger.kernel.org
> Subject: Re: [net-next 1/8] pci: Add flag indicating device has been
> assigned by KVM [and Xen]
> 
> On Fri, Sep 23, 2011 at 09:41:39PM -0700, Jeff Kirsher wrote:
> > On Fri, 2011-09-23 at 12:05 -0700, Konrad Rzeszutek Wilk wrote:
> > > > > > Version 2 of this patch with the modified comment was just
> posted to
> > > > > netdev.  Ian Campbell had mentioned that the Xen pciback driver
> should be
> > > > > modified to use this flag but I don't believe any patches for it
> have been
> > > > > created yet.
> > > > >
> > > > > http://marc.info/?i=20110729165446.GA6731@dumpdata.com
> ..
> Any plans to support bnx4 and igb with this feature?

I'm updating the igb driver to support this feature right now.  I would hesitate to get into other drivers and muck with them because the changes to support this feature are not trivial and also involve policy decisions that I'd prefer to leave up to the folks who maintain those drivers.  Plus I have no other vendor hardware available to test the changes.

> Any ETA?

I should have the igb driver work done in the next week or so.

- Greg
