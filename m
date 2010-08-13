From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] Add firmware label support to iproute2
Date: Fri, 13 Aug 2010 18:06:26 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com> <20100812141240.417949e2@s6510>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Charles_Rose@Dell.com>, <Jordan_Hargrave@Dell.com>
To: <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:33709 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab0HMMgk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 08:36:40 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100812141240.417949e2@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Thursday, August 12, 2010 11:43 PM
> To: K, Narendra
> Cc: netdev@vger.kernel.org; Domsch, Matt; Rose, Charles; Hargrave,
> Jordan
> Subject: Re: [PATCH] Add firmware label support to iproute2
> 
> On Thu, 12 Aug 2010 12:35:37 -0500
> Narendra K <Narendra_K@dell.com> wrote:
> 
> > +#ifndef LIBNETDEVNAME_PRESENT
> >  			filter_dev = *argv;
> > +#else
> > +			if (netdev_alias_to_kernelname(*argv,
kernel_name) <
> 0)
> > +				show_firmware_alias_usage(*argv);
> > +			filter_dev = kernel_name;
> > +#endif
> >  		}
> 
> like the kernel, I don't like ifdef cases in main code.
> You should put in stub inline that returns appropriate error.
> 

Stephen,

Thanks for the suggestions. I will rework the patch and send a revised
version soon.

> What happens if alias matches existing interface name?

If the user inputs an existing 'ethN' name, the function
'netdev_alias_to_kernelaname' will return it as it is. If the user
inputs 'Embedded NIC N', then the function would do a sysfs lookup and
return the corresponding 'ethN' name.

With regards,
Narendra K


