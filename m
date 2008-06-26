From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [patch v3 01/12] DM9000: Remove the 2 resources probe scheme.
Date: Thu, 26 Jun 2008 13:42:19 +0100
Message-ID: <20080626124219.GA4289@fluff.org.uk>
References: <20080624211556.566149406@fluff.org.uk> <20080624211903.586586947@fluff.org.uk> <4861B63D.1010509@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	laurentp@cse-semaphore.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:61782 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756984AbYFZMm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 08:42:29 -0400
Content-Disposition: inline
In-Reply-To: <4861B63D.1010509@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2008 at 11:06:37PM -0400, Jeff Garzik wrote:
> Ben Dooks wrote:
>> From: Laurent Pinchart <laurentp@cse-semaphore.com>
>>
>> The dm9000 driver accepts either 2 or 3 resources to describe the platform
>> devices. The 2 resources case abuses the ioresource mechanism by passing
>> ioremap()ed memory through the platform device resources. This patch removes
>> that case and converts boards that were using it to the 3 resources scheme.
>>
>> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
>> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
>
> applied 1-12

Great, thankyou.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
