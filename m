From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [net-next 1/8] pci: Add flag indicating device has been assigned
 by KVM
Date: Fri, 23 Sep 2011 14:00:26 -0400
Message-ID: <20110923180025.GA6251@phenom.oracle.com>
References: <1316599974-23205-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1316599974-23205-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAL3LdT7jDfytZD7WESmiHxvpmxKTEZ=uWRjzgsR9e4GtBPE31A@mail.gmail.com>
 <1316762872.23371.88.camel@zakaz.uk.xensource.com>
 <43F901BD926A4E43B106BF17856F0755019C518C0E@orsmsx508.amr.corp.intel.com>
 <1316790220.23371.105.camel@zakaz.uk.xensource.com>
 <43F901BD926A4E43B106BF17856F0755019C518C47@orsmsx508.amr.corp.intel.com>
 <1316792710.2182.124.camel@jtkirshe-mobl>
 <20110923164326.GA23363@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C518D57@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Ian Campbell <ijc@hellion.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019C518D57@orsmsx508.amr.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 23, 2011 at 10:04:59AM -0700, Rose, Gregory V wrote:
> > -----Original Message-----
> > From: Konrad Rzeszutek Wilk [mailto:konrad.wilk@oracle.com]
> > Sent: Friday, September 23, 2011 9:43 AM
> > To: Kirsher, Jeffrey T
> > Cc: Rose, Gregory V; Ian Campbell; davem@davemloft.net; Jesse Barnes;
> > netdev@vger.kernel.org; gospo@redhat.com; linux-pci@vger.kernel.org
> > Subject: Re: [net-next 1/8] pci: Add flag indicating device has been
> > assigned by KVM
> > 
> > On Fri, Sep 23, 2011 at 08:45:09AM -0700, Jeff Kirsher wrote:
> > > On Fri, 2011-09-23 at 08:11 -0700, Rose, Gregory V wrote:
> > > > > -----Original Message-----
> > > > > From: Ian Campbell [mailto:ijc@hellion.org.uk]
> > > > > Sent: Friday, September 23, 2011 8:04 AM
> > > > > To: Rose, Gregory V
> > > > > Cc: Kirsher, Jeffrey T; davem@davemloft.net; konrad.wilk@oracle.com;
> > Jesse
> > > > > Barnes; netdev@vger.kernel.org; gospo@redhat.com; linux-
> > > > > pci@vger.kernel.org
> > > > > Subject: RE: [net-next 1/8] pci: Add flag indicating device has been
> > > > > assigned by KVM
> > > > >
> > > > > On Fri, 2011-09-23 at 07:41 -0700, Rose, Gregory V wrote:
> > > > > > > -----Original Message-----
> > > > > > > From: Ian Campbell [mailto:ijc@hellion.org.uk]
> > > > > > > Sent: Friday, September 23, 2011 12:28 AM
> > > > > > > To: Kirsher, Jeffrey T
> > > > > > > Cc: davem@davemloft.net; konrad.wilk@oracle.com; Jesse Barnes;
> > Rose,
> > > > > > > Gregory V; netdev@vger.kernel.org; gospo@redhat.com; linux-
> > > > > > > pci@vger.kernel.org
> > > > > > > Subject: Re: [net-next 1/8] pci: Add flag indicating device has
> > been
> > > > > > > assigned by KVM
> > > > > > >
> > > > > > > I suppose by that measure the comment could be less KVM
> > specific:
> > > > > > > > +       /* Provide indication device is assigned by KVM */
> > > > > > > > +       PCI_DEV_FLAGS_ASSIGNED = (__force pci_dev_flags_t) 4,
> > > > > >
> > > > > > We can resubmit with a more generic comment, maybe this:
> > > > > >
> > > > > > /* Provide indication device is assigned by a Virtual Machine
> > Manager */
> > > > >
> > > > > Sounds good to me.
> > > >
> > > > Dave, Jeff,
> > > >
> > > > Should I resubmit the patch or would it be more convenient to post a
> > follow on patch that fixes up the comment?  Either way is fine by me.
> > > >
> > > > - Greg
> > > >
> > >
> > > let's fix up the patch in my tree and add Jesse Barnes's ACK at the same
> > > time.
> > 
> > Were are the patches now? I am kind of curious to see the changes to the
> > xen pciback.
> > 
> > 
> 
> Version 2 of this patch with the modified comment was just posted to netdev.  Ian Campbell had mentioned that the Xen pciback driver should be modified to use this flag but I don't believe any patches for it have been created yet.

http://marc.info/?i=20110729165446.GA6731@dumpdata.com

?
