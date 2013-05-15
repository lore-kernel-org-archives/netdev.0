From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BCM5719(tg3) use multiple MSI with RSS
Date: Wed, 15 May 2013 09:03:56 -0700
Message-ID: <1368633836.6796.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <51933FCB.4090402@linux.vnet.ibm.com>
 <1368630538.3768.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <1368633120.2652.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "Mike Qiu" <qiudayu@linux.vnet.ibm.com>, eilong@broadcom.com,
	mcarlson@broadcom.com, zambrano@broadcom.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1772 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758425Ab3EOQEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 12:04:11 -0400
In-Reply-To: <1368633120.2652.11.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-15 at 16:52 +0100, Ben Hutchings wrote: 
> On Wed, 2013-05-15 at 08:08 -0700, Michael Chan wrote:
> > On Wed, 2013-05-15 at 15:56 +0800, Mike Qiu wrote: 
> > > Hi all
> > > 
> > > Currently, I need to enable multiple MSI on BCM5719 network card.
> > > But I look in to the spec of 5719 from Broadcom, it seems
> > > that RSS just enable with MSI-X, so I'm not sure if multiple
> > > MSI can use RSS.
> > > 
> > 
> > MSI can only support one IRQ source and cannot support RSS.
> 
> It is possible for an MSI capability to have multiple MSIs, but they
> will use the same address and consecutive data values.
> 
> On x86, if you can find a large enough block of free IRQs on an IOAPIC,
> it is possible to implement RSS this way.  Linux supports this on
> systems with an x2apic.
> 
> Now, maybe tg3 hardware doesn't support this (and really, why bother
> when there is MSI-X?) but the option does exist.

Yes, tg3 hardware (may be all Broadcom hardware) can only use MSI as a
replacement for INTA.
