From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/3] netxen: fix lro buffer allocation
Date: Thu, 03 Sep 2009 20:06:15 -0700 (PDT)
Message-ID: <20090903.200615.220020629.davem@davemloft.net>
References: <1252019455-30683-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org, dhananjay@qlogic.com
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50992
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932645AbZIDDGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:06:00 -0400
In-Reply-To: <1252019455-30683-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Thu,  3 Sep 2009 16:10:53 -0700

> From: Dhananjay Phadke <dhananjay@qlogic.com>
> 
> Alloc 12k skbuffs so that firmware can aggregate more
> packets into one buffer. This doesn't raise memory
> consumption since 9k skbs use 16k slab cache anyway.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.  But allocating such huge linear buffers is asking for
guarenteed trouble.  Can't you split them up into page sized chunks
with this chip?
