From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Export SMBIOS provided firmware instance and label to
	sysfs
Date: Tue, 20 Jul 2010 20:54:04 -0700
Message-ID: <20100721035404.GE16676@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612B93@blrx3m08.blr.amer.dell.com> <20100714121345.GA20411@auslistsprd01.us.dell.com> <EDA0A4495861324DA2618B4C45DCB3EE612BD1@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, Matt_Domsch@Dell.com,
	Charles_Rose@Dell.com, Jordan_Hargrave@Dell.com,
	Vijay_Nijhawan@Dell.com
To: Narendra_K@Dell.com
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE612BD1@blrx3m08.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 19, 2010 at 10:24:39PM +0530, Narendra_K@Dell.com wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Narendra K
> > Sent: Wednesday, July 14, 2010 5:44 PM
> > To: greg@kroah.com
> > Cc: netdev@vger.kernel.org; linux-hotplug@vger.kernel.org; linux-
> > pci@vger.kernel.org; Domsch, Matt; Rose, Charles; Hargrave, Jordan;
> > Nijhawan, Vijay
> > Subject: Re: [PATCH] Export SMBIOS provided firmware instance and
> label
> > to sysfs
> > 
> > 
> > V1 -> V2:
> > 
> > 1. The 'smbios_attr' buffer is not being used as mentioned above
> > 
> > 2. The function 'smbios_instance_string_exist' is split into two
> > functions,
> > the other being 'find_smbios_instance_string' which would print the
> > result
> > into the sysfs provided 'buf' of associated device. The function
> > 'smbios_instance_string_exist' would let us know if the label exists
> or
> > not.
> > 
> > Please find the patch with above changes here -
> > 
> > From: Narendra K <narendra_k@dell.com>
> > Subject: [PATCH] Export SMBIOS provided firmware instance and label to
> > sysfs
> > 
> 
> Greg,
> 
> Thanks for the review comments. 
> 
> This version of the patch has all the suggestions incorporated. Please
> let us know if there are any concerns. If the approach is acceptable,
> please consider this patch for inclusion.

What "version"?  The previous one you sent?  I'll look at it, but note
that I'm not the maintainer who you need to convince to accept it :)

thanks,

greg k-h
