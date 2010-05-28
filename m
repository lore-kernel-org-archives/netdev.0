From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH 1/2] Export firmware assigned labels of network devices to sysfs
Date: Fri, 28 May 2010 13:11:00 -0500
Message-ID: <20100528181100.GA12806@auslistsprd01.us.dell.com>
References: <20100528115520.GA24114@littleblue.us.dell.com> <20100528154041.GA27186@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "K, Narendra" <Narendra_K@dell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@dell.com>,
	"Rose, Charles" <Charles_Rose@dell.com>,
	"Nijhawan, Vijay" <Vijay_Nijhawan@dell.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100528154041.GA27186@kroah.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 28, 2010 at 08:40:41AM -0700, Greg KH wrote:
> On Fri, May 28, 2010 at 06:55:21AM -0500, K, Narendra wrote:
> > +static const char dell_dsm_uuid[] = {
> 
> Um, a dell specific uuid in a generic file?  What happens when we need
> to support another manufacturer?
> 
> > +       0xD0, 0x37, 0xC9, 0xE5, 0x53, 0x35, 0x7A, 0x4D,
> > +       0x91, 0x17, 0xEA, 0x4D, 0x19, 0xC3, 0x43, 0x4D
> > +};

This simply needs to be renamed.  It's defined in the ECN, so will be
part of the spec, and is not vendor-unique, but defined once for all
implementations.  It separates this _DSM function from others.

Thanks for the quick feedback.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
