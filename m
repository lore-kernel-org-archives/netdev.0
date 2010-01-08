From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] drivers/net/: use DEFINE_PCI_DEVICE_TABLE()
Date: Fri, 8 Jan 2010 09:34:47 +0200
Message-ID: <20100108073447.GA4070@x200>
References: <20100107215811.GA9357@x200>
 <1262903146.10429.83.camel@Joe-Laptop.home>
 <4B465FF0.80802@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:31812 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab0AHHew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 02:34:52 -0500
Received: by fg-out-1718.google.com with SMTP id 22so7608335fge.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2010 23:34:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B465FF0.80802@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2010 at 05:28:00PM -0500, Jeff Garzik wrote:
> On 01/07/2010 05:25 PM, Joe Perches wrote:
> > On Thu, 2010-01-07 at 23:58 +0200, Alexey Dobriyan wrote:
> >> Use DEFINE_PCI_DEVICE_TABLE() so we get place PCI ids table into correct section
> >> in every case.
> >
> > Good idea, but aren't there are some tables that are not const?
> 
> I hope not...  those tables are read by userland tools.

I checked non-static ones, they are readonly.
and PCI layer expects them to be readonly.

> Messing with the PCI ID tables as runtime is highly unusual, to say the 
> least.
