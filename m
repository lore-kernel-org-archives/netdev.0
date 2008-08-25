From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 1/3] enic: add Makefile, patch Kconfg, MAINTAINERS, etc
Date: Mon, 25 Aug 2008 15:27:57 -0700
Message-ID: <adaprnwlogi.fsf@cisco.com>
References: <Pine.LNX.4.64.0808251121150.3972@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:9128 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851AbYHYW16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 18:27:58 -0400
In-Reply-To: <Pine.LNX.4.64.0808251121150.3972@palito_client100.nuovasystems.com>
	(Scott Feldman's message of "Mon, 25 Aug 2008 11:26:41 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Overall, looks quite good.  Very clean, just a few comments here and there:

 > +#define PCI_VENDOR_ID_CISCO		0x1137
 > +#define PCI_DEVICE_ID_CISCO_ENIC	0x0043

the current convention is that we don't put IDs that are only used in
one place into pci_ids.h.  I guess the vendor ID can stay but the device
ID is probably not needed here (just put it in the driver file where
it's used, if anywhere).

 - R.
