From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: E1000 (PCI-E) doesn't work on nforce430, MSI issue.
Date: Tue, 12 Feb 2008 14:24:21 -0800
Message-ID: <47B21C95.4050705@intel.com>
References: <m37ih9ooim.fsf@maximus.localdomain> <200802122234.47164.prakash@punnoor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Prakash Punnoor <prakash@punnoor.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3724 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788AbYBLWZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 17:25:08 -0500
In-Reply-To: <200802122234.47164.prakash@punnoor.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prakash Punnoor wrote:
> On the day of Tuesday 12 February 2008 Krzysztof Halasa hast written:
>> Hi,
>>
>> Is it a known problem?
>> Linux 2.6.24.2, ASUS M2NPV-MX mobo, nforce 430 based, two PCI-E x1
>> E1000 cards, 32-bit kernel, default e1000 driver (PCI IDs disabled in
>> e1000e).

your card will work with e1000e from 2.6.25 onwards.

>> Don't work by default. "pci=nomsi" fixes the problem.

actually does not fix anything - it just works around it by falling back to legacy
interrupts.

> Probably the patch to enable msi bit on the host bridge(?) is still missing in 
> mainline. I needed that patch to make msi work on my MCP51 system.

and there have been many more reports. unfortunately e1000 cards are one of the
few things that actually uses MSI. It works great except for a few problematic
motherboards, and the ones mentioned in this thread fall amongst them.

Auke
