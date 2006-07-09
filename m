From: Anthony DeRobertis <asd@suespammers.org>
Subject: Re: skge error; hangs w/ hardware memory hole
Date: Sun, 09 Jul 2006 11:24:17 -0400
Message-ID: <44B11FA1.8070905@suespammers.org>
References: <20060703205238.GA10851@deprecation.cyrius.com> <20060707141843.73fc6188@dxpl.pdx.osdl.net> <200607072328.51282.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Martin Michlmayr <tbm@cyrius.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, 341801@bugs.debian.org,
	kevin@sysexperts.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Maxwell.derobert.net ([207.188.193.82]:23688 "EHLO
	Maxwell.derobert.net") by vger.kernel.org with ESMTP
	id S1161024AbWGIPYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 11:24:43 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200607072328.51282.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

> Is that a board with VIA chipset?

Yep.

> 
> VIA doesn't seem to support PCI accesses with addresses >4GB and they also
> don't have a working GART IOMMU.
> 
> It will likely work with iommu=force

I'll give this a try.... I do get a line in dmesg which reads:

PCI-DMA: Disabling IOMMU.
