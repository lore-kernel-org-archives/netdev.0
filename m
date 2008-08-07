From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1.2.32] WAN: merge driver retina
Date: Thu, 07 Aug 2008 02:31:14 -0400
Message-ID: <489A96B2.4030903@pobox.com>
References: <ca0148c30807032339o4182fbadq370f709a28861053@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matti Linnanvuori <mattilinn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52012 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756453AbYHGGbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:31:17 -0400
In-Reply-To: <ca0148c30807032339o4182fbadq370f709a28861053@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matti Linnanvuori wrote:
> The following patch is based on linux-next:
> http://pcidriver.googlegroups.com/web/retina-patch.txt?gda=Hj6V2UEAAAD9a223ZdyQxc6jQf5toR434ka3fTOuf9SStRjUQ9KuyGG1qiJ7UbTIup-M2XPURDRb8A7WwO6f6JZwMwSZaAwRMXXBcZFbXU7ojtsMSuO4sA
> The build error and the warnings reported by David Miller have been fixed.

The version I reviewed uses virt_to_bus(), which should not be used in 
modern drivers.  The DMA API should be used instead.

A couple months ago I created a 'retina' branch of 
jgarzik/netdev-2.6.git containing your latest code.  If you could send 
patches against that, that would be helpful in reviewing the 
improvements you make to the driver, and help us get this into the kernel.

	Jeff



