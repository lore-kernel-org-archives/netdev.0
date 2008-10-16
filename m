From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch v1.2.34] WAN: merge driver retina
Date: Thu, 16 Oct 2008 05:34:08 -0400
Message-ID: <48F70A90.4080007@pobox.com>
References: <ca0148c30807032339o4182fbadq370f709a28861053@mail.gmail.com> <489A96B2.4030903@pobox.com> <ca0148c30808072334w5d2d8216s37152621b4aa8ebf@mail.gmail.com> <ca0148c30808120246w5c2eca09u3bfa08e3ea40cfe4@mail.gmail.com> <48CC57EB.9010500@pobox.com> <ca0148c30809300251y37070034m20efd3e65caa868e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matti Linnanvuori <mattilinn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60237 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754346AbYJPJeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 05:34:12 -0400
In-Reply-To: <ca0148c30809300251y37070034m20efd3e65caa868e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matti Linnanvuori wrote:
> 2008/9/14 Jeff Garzik <jgarzik@pobox.com>:
>> Changes look good, but do not apply to the 'retina' branch.  Also, the
>> virt_to_bus/virt_to_phys stuff should be replaced with DMA mapping API
>> usage.
> 
> Actually there is one call of virt_to_phys in the patch I sent.
> I don't know any way to replace virt_to_phys and still use remap_pfn_range.
> If all architectures support virt_to_phys, I see no reason to replace it with
> something else. The driver is legacy.

We do not merge new drivers that use deprecated APIs.

The whole point of a deprecated API is that you wish to remove it 
eventually.

	Jeff


