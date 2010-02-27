From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] cxgb4: Add packet queues and packet DMA code
Date: Sat, 27 Feb 2010 01:48:39 -0800 (PST)
Message-ID: <20100227.014839.226753616.davem@davemloft.net>
References: <8A71B368A89016469F72CD08050AD33401359B69@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33507
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S968079Ab0B0JsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 04:48:21 -0500
In-Reply-To: <8A71B368A89016469F72CD08050AD33401359B69@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dimitrios Michailidis" <dm@chelsio.com>
Date: Fri, 26 Feb 2010 16:10:07 -0800

> I believe this function does not generate any code, the compiler
> statically figures out the result and optimizes any conditionals that
> call it.  What option do you have in mind that would tell the compiler
> if unmap is nop?

I've got better questions:

1) Why is your driver so damn special?

   If this optimization is useful, it dosn't belong privately in
   some driver, it belongs in some generic spot.

2) What configuration does this even help for?  Even bog standard x86
   and x86_64 uses IOMMUs and thus make use of the unmap address.

   I cannot think of one platform that matters where this will even
   trigger.

Get rid of this junk, please.  Because even if it's valid, it doesn't
belong privately in your driver.

