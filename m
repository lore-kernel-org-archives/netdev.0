From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bnx2x: dont handle storage drv_info req
 if no cnic
Date: Wed, 07 Dec 2011 13:45:48 -0500 (EST)
Message-ID: <20111207.134548.419727966018690088.davem@davemloft.net>
References: <Barak_Witkowski_<barak@broadcom.com>
	<1323265536-9760-1-git-send-email-barak@broadcom.com>
	<1323277440.1762.46.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: barak@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756968Ab1LGSpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 13:45:54 -0500
In-Reply-To: <1323277440.1762.46.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 07 Dec 2011 09:04:00 -0800

> On Wed, 2011-12-07 at 15:45 +0200, Barak Witkowski wrote:
>> This patch returns ACK with zeroed buffer to FW upon fcoe/iscsi drv_info
>> request if cnic is not defined. This is better handling in comparison to
>> send NACK to FW upon such request, as it's a valid request.
> 
> Hi Barak.
> 
> Other than the good comment,
> I think this patch isn't useful.
> It adds maintenance overhead.
> 
> It just adds more #ifdefs.
> 
> gcc should remove the call to the
> empty static void funcs.

Agreed, I'm not applying this patch.
