From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: question on sky2 driver panic
Date: Mon, 15 Oct 2007 23:16:16 -0600
Message-ID: <47144920.4010402@nortel.com>
References: <4713CAEE.6010106@nortel.com> <20071015150408.22f31d77@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:35902 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758909AbXJPFQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 01:16:46 -0400
In-Reply-To: <20071015150408.22f31d77@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> Maybe TIPC can't handle fragmented receive buffers.  The sky2 driver
> generates skb's with header and multiple pages if MTU is big enough.
> For 9K MTU that would be 1K of data + 2 4K pages.  The protocols are
> supposed to be smart enough to handle this, but TIPC is rarely used.

We already had to modify tipc to handle fragmented receive buffers when 
we had memory allocation errors on the e1000 and moved to fragmented 
skbs in that driver.

Our version of the e1000 passes 200 bytes in the initial chunk, and the 
rest in fragments.  tipc currently handles that without any difficulty.

I was just checking more to see if there were any known issues in this 
area that have been fixed in more recent driver versions.

Chris

