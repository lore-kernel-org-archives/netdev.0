From: David Miller <davem@davemloft.net>
Subject: Re: [patch v1.2.34] WAN: merge driver retina
Date: Thu, 16 Oct 2008 02:35:47 -0700 (PDT)
Message-ID: <20081016.023547.73315545.davem@davemloft.net>
References: <48CC57EB.9010500@pobox.com>
	<ca0148c30809300251y37070034m20efd3e65caa868e@mail.gmail.com>
	<48F70A90.4080007@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mattilinn@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51781
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751886AbYJPJgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 05:36:11 -0400
In-Reply-To: <48F70A90.4080007@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jgarzik@pobox.com>
Date: Thu, 16 Oct 2008 05:34:08 -0400

> Matti Linnanvuori wrote:
> > 2008/9/14 Jeff Garzik <jgarzik@pobox.com>:
> >> Changes look good, but do not apply to the 'retina' branch.  Also, the
> >> virt_to_bus/virt_to_phys stuff should be replaced with DMA mapping API
> >> usage.
> > Actually there is one call of virt_to_phys in the patch I sent.
> > I don't know any way to replace virt_to_phys and still use remap_pfn_range.
> > If all architectures support virt_to_phys, I see no reason to replace it with
> > something else. The driver is legacy.
> 
> We do not merge new drivers that use deprecated APIs.
> 
> The whole point of a deprecated API is that you wish to remove it eventually.

Note that virt_to_phys() is not a problem.

It's only virt_to_bus() that mustn't be used.

