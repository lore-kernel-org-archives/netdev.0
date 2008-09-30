From: "Matti Linnanvuori" <mattilinn@gmail.com>
Subject: Re: [patch v1.2.34] WAN: merge driver retina
Date: Tue, 30 Sep 2008 12:51:52 +0300
Message-ID: <ca0148c30809300251y37070034m20efd3e65caa868e@mail.gmail.com>
References: <ca0148c30807032339o4182fbadq370f709a28861053@mail.gmail.com>
	 <489A96B2.4030903@pobox.com>
	 <ca0148c30808072334w5d2d8216s37152621b4aa8ebf@mail.gmail.com>
	 <ca0148c30808120246w5c2eca09u3bfa08e3ea40cfe4@mail.gmail.com>
	 <48CC57EB.9010500@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:31728 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbYI3Jvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 05:51:53 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2783405rvb.1
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 02:51:52 -0700 (PDT)
In-Reply-To: <48CC57EB.9010500@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/9/14 Jeff Garzik <jgarzik@pobox.com>:
> Changes look good, but do not apply to the 'retina' branch.  Also, the
> virt_to_bus/virt_to_phys stuff should be replaced with DMA mapping API
> usage.

Actually there is one call of virt_to_phys in the patch I sent.
I don't know any way to replace virt_to_phys and still use remap_pfn_range.
If all architectures support virt_to_phys, I see no reason to replace it with
something else. The driver is legacy.
