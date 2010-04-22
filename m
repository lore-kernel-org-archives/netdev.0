From: David Miller <davem@davemloft.net>
Subject: Re: [patch] wimax: wimax_msg_alloc() returns ERR_PTR not null
Date: Thu, 22 Apr 2010 15:56:30 -0700 (PDT)
Message-ID: <20100422.155630.10951183.davem@davemloft.net>
References: <20100422094632.GM29647@bicker>
	<1271973596.2867.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, netdev@vger.kernel.org, andre.goddard@gmail.com,
	kernel-janitors@vger.kernel.org, wimax@linuxwimax.org,
	linux-wimax@intel.com
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52265
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753459Ab0DVW4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 18:56:25 -0400
In-Reply-To: <1271973596.2867.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Thu, 22 Apr 2010 14:59:56 -0700

> On Thu, 2010-04-22 at 11:46 +0200, Dan Carpenter wrote: 
>> wimax_msg_alloc() returns an ERR_PTR and not null.  I changed it to test
>> for ERR_PTR instead of null.  I also added a check in front of the
>> kfree() because kfree() can handle null but not ERR_PTR.
>> 
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> Good catch thank you!
> 
> Will merge ASAP in preparation for the next push

There was another wimax fix from Dan, subject:

	[patch] wimax: checking ERR_PTR vs null

make sure you integrate that one too.
