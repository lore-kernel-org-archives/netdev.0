From: <Jordan_Hargrave@Dell.com>
Subject: RE: [PATCH V4] Export ACPI _DSM provided firmware instance number
 and string name to sysfs
Date: Wed, 9 Mar 2011 18:35:24 -0600
Message-ID: <5B3AAEAF6B46EA4D955DF7AD46C2C48502C2A7A9@AUSX7MCPS303.AMER.DELL.COM>
References: <20110223125741.GA16473@fedora14-r610.blr.amer.dell.com>
 <20110302172508.GA2794@fedora14-r610.oslab.blr.amer.dell.com>
 <20110304104314.26265021@jbarnes-desktop>
 <AANLkTimz662+L6eYJm2gh0NwWOxxzQV3503bcs-GMFGu@mail.gmail.com>
 <20110307200512.GA22450@fedora14-r610.oslab.blr.amer.dell.com>
 <20110307195616.GA14888@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <a.beregalov@gmail.com>, <linux-next@vger.kernel.org>,
	<jbarnes@virtuousgeek.org>, <linux-pci@vger.kernel.org>,
	<linux-hotplug@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mjg@redhat.com>, <Matt_Domsch@Dell.com>, <Charles_Rose@Dell.com>,
	<Shyam_Iyer@Dell.com>, <sfr@canb.auug.org.au>
To: <greg@kroah.com>, <Narendra_K@Dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20110307195616.GA14888@kroah.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That happens though for CONFIG_XXXX, though usually the include file is further down in the #ifdef region.


--jordan hargrave
Dell Enterprise Linux Engineering

-----Original Message-----
From: Greg KH [mailto:greg@kroah.com] 
Sent: Monday, March 07, 2011 1:56 PM
To: K, Narendra
Cc: a.beregalov@gmail.com; linux-next@vger.kernel.org; jbarnes@virtuousgeek.org; linux-pci@vger.kernel.org; linux-hotplug@vger.kernel.org; netdev@vger.kernel.org; mjg@redhat.com; Domsch, Matt; Rose, Charles; Hargrave, Jordan; Iyer, Shyam; sfr@canb.auug.org.au
Subject: Re: [PATCH V4] Export ACPI _DSM provided firmware instance number and string name to sysfs

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
