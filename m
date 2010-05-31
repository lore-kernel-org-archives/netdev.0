From: <Narendra_K@Dell.com>
Subject: RE: [PATCH 1/2] Export firmware assigned labels of network devices to sysfs
Date: Mon, 31 May 2010 13:25:34 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE61285B@blrx3m08.blr.amer.dell.com>
References: <20100528115520.GA24114@littleblue.us.dell.com> <20100528154041.GA27186@kroah.com> <20100528181100.GA12806@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <Jordan_Hargrave@Dell.com>,
	<Charles_Rose@Dell.com>, <Vijay_Nijhawan@Dell.com>
To: <Matt_Domsch@Dell.com>, <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20100528181100.GA12806@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Matt Domsch [mailto:Matt_Domsch@dell.com]
> Sent: Friday, May 28, 2010 11:41 PM
> To: Greg KH
> Cc: K, Narendra; netdev@vger.kernel.org;
linux-hotplug@vger.kernel.org;
> linux-pci@vger.kernel.org; Hargrave, Jordan; Rose, Charles; Nijhawan,
> Vijay
> Subject: Re: [PATCH 1/2] Export firmware assigned labels of network
> devices to sysfs
> 
> On Fri, May 28, 2010 at 08:40:41AM -0700, Greg KH wrote:
> > On Fri, May 28, 2010 at 06:55:21AM -0500, K, Narendra wrote:
> > > +static const char dell_dsm_uuid[] = {
> >
> > Um, a dell specific uuid in a generic file?  What happens when we
> need
> > to support another manufacturer?
> >
> > > +       0xD0, 0x37, 0xC9, 0xE5, 0x53, 0x35, 0x7A, 0x4D,
> > > +       0x91, 0x17, 0xEA, 0x4D, 0x19, 0xC3, 0x43, 0x4D
> > > +};
> 
> This simply needs to be renamed.  It's defined in the ECN, so will be
> part of the spec, and is not vendor-unique, but defined once for all
> implementations.  It separates this _DSM function from others.
> 
> Thanks for the quick feedback.

Matt,

Thanks for the clarification. My understanding of the uuid was
incorrect. Would address this in the next version of the patch.

With regards,
Narendra K
