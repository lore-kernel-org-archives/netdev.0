From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 01/24 for-2.6.25] DM9000: Fix endian-ness of data accesses.
 Patch from: Laurent Pinchart <laurentp@cse-semaphore.com>
Date: Thu, 07 Feb 2008 09:54:12 -0500
Message-ID: <47AB1B94.50304@garzik.org>
References: <20080205000159.432081941@fluff.org.uk> <20080205000814.539308209@fluff.org.uk> <47A99E1A.3050808@garzik.org> <200802071428.38849.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, daniel@caiaq.de
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54741 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755113AbYBGOyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 09:54:17 -0500
In-Reply-To: <200802071428.38849.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laurent Pinchart wrote:
> On Wednesday 06 February 2008 12:46, Jeff Garzik wrote:
>> two comments:
>>
>> 1) you should be using __le16 type
>>
>> 2) seems like you should do the same for RxStatus, rather than splitting it
> 
> The DM9000 datasheet (or rather the application notes) describes two distinct 
> fields, even though they both contain some kind of status information.

Sure, there are plenty of distinct fields, just like with every chipset. 
  That doesn't mean byte instructions are the best choice.

	Jeff



