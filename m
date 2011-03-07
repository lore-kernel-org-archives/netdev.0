From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH V4] Export ACPI _DSM provided firmware instance number
 and string name to sysfs
Date: Mon, 7 Mar 2011 11:56:16 -0800
Message-ID: <20110307195616.GA14888@kroah.com>
References: <20110223125741.GA16473@fedora14-r610.blr.amer.dell.com>
 <20110302172508.GA2794@fedora14-r610.oslab.blr.amer.dell.com>
 <20110304104314.26265021@jbarnes-desktop>
 <AANLkTimz662+L6eYJm2gh0NwWOxxzQV3503bcs-GMFGu@mail.gmail.com>
 <20110307200512.GA22450@fedora14-r610.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: a.beregalov@gmail.com, linux-next@vger.kernel.org,
	jbarnes@virtuousgeek.org, linux-pci@vger.kernel.org,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	mjg@redhat.com, Matt_Domsch@Dell.com, Charles_Rose@Dell.com,
	Jordan_Hargrave@Dell.com, Shyam_Iyer@Dell.com, sfr@canb.auug.org.au
To: Narendra_K@Dell.com
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110307200512.GA22450@fedora14-r610.oslab.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 07, 2011 at 11:44:52AM -0800, Narendra_K@Dell.com wrote:
> --- a/drivers/pci/pci-label.c
> +++ b/drivers/pci/pci-label.c
> @@ -29,7 +29,9 @@
>  #include <linux/nls.h>
>  #include <linux/acpi.h>
>  #include <linux/pci-acpi.h>
> +#ifdef CONFIG_ACPI
>  #include <acpi/acpi_drivers.h>
> +#endif

You should never need a #ifdef in a .c file for an include file.  If so,
something is really wrong.

thanks,

greg k-h
