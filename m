From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH V2] Use firmware provided index to register a network
 interface
Date: Thu, 7 Oct 2010 08:11:34 -0700
Message-ID: <20101007151134.GA25713@kroah.com>
References: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, Matt_Domsch@Dell.com,
	Jordan_Hargrave@Dell.com, Vijay_Nijhawan@Dell.com,
	Charles_Rose@Dell.com
To: Narendra_K@Dell.com
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 07, 2010 at 07:23:35AM -0700, Narendra_K@Dell.com wrote:
> Hello,
> 
> V1 -> V2:
> 
> This patch addresses the scenario of buggy firmware/BIOS tables. The
> patch introduces a command line parameter 'no_netfwindex', passing which
> firmware provided index will not be used to derive 'eth' names. By
> default, firmware index will be used and the parameter can be used to
> work around buggy firmware/BIOS tables.
> 
> Please find the patch below.
> 
> From: Narendra K <narendra_k@dell.com>
> Subject: [PATCH] Use firmware provided index to register a network device
> 
> This patch uses the firmware provided index to derive the ethN name.
> If the firmware provides an index for the corresponding pdev, the N
> is derived from the index.

No, this has the very big chance to reorder existing network names and
should all be done in userspace with the firmware information exported
in sysfs, if the user so desires.

So consider this patch rejected from me.

thanks,

greg k-h
