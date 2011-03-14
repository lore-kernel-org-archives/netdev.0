From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Disable rp_filter for IPsec packets
Date: Mon, 14 Mar 2011 15:27:04 -0700 (PDT)
Message-ID: <20110314.152704.98879085.davem@davemloft.net>
References: <4D7E928C.1030707@cbnco.com>
	<20110314.151424.212690587.davem@davemloft.net>
	<4D7E9558.7030102@cbnco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: msmith@cbnco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59991
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756489Ab1CNW00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:26:26 -0400
In-Reply-To: <4D7E9558.7030102@cbnco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Smith <msmith@cbnco.com>
Date: Mon, 14 Mar 2011 18:23:20 -0400

> David Miller wrote:
> 
>> Existing arguments might be large enough to carry more than one piece
>> of information :-)
> 
> If it's encoded into another argument, would there be more overhead
> from bit-shifting it out than you'd save by losing an argument?

It sure will if it's the different between the argument being passed
in a register vs. on the stack.
