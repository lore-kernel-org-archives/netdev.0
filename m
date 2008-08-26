From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [RFC][PATCH 1/3] enic: add Makefile, patch Kconfg, MAINTAINERS,
 etc
Date: Tue, 26 Aug 2008 10:42:03 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0808261039300.11710@palito_client100.nuovasystems.com>
References: <adaprnwlogi.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Scott Feldman <scofeldm@cisco.com>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:41595 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756903AbYHZRuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 13:50:15 -0400
In-Reply-To: <adaprnwlogi.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Aug 2008, Roland Dreier wrote:

> Overall, looks quite good.  Very clean, just a few comments here and there:

Thanks for the review Roland.  I'll give a day or two for more review and 
repost the patches.

> > +#define PCI_VENDOR_ID_CISCO		0x1137
> > +#define PCI_DEVICE_ID_CISCO_ENIC	0x0043
>
> the current convention is that we don't put IDs that are only used in
> one place into pci_ids.h.  I guess the vendor ID can stay but the device
> ID is probably not needed here (just put it in the driver file where
> it's used, if anywhere).

Ok

-scott
