From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Disable rp_filter for IPsec packets
Date: Tue, 15 Mar 2011 16:35:52 -0700 (PDT)
Message-ID: <20110315.163552.183047357.davem@davemloft.net>
References: <4D7E9558.7030102@cbnco.com>
	<20110314.152704.98879085.davem@davemloft.net>
	<Pine.LNX.4.64.1103151913340.28997@juice.ott.cti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: msmith@cbnco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42056
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751366Ab1COXfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 19:35:14 -0400
In-Reply-To: <Pine.LNX.4.64.1103151913340.28997@juice.ott.cti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Smith <msmith@cbnco.com>
Date: Tue, 15 Mar 2011 19:21:29 -0400 (EDT)

> On Mon, 14 Mar 2011, David Miller wrote:
> 
>> > David Miller wrote:
>> > 
>> >> Existing arguments might be large enough to carry more than one piece
>> >> of information :-)
>> > 
>> > If it's encoded into another argument, would there be more overhead
>> > from bit-shifting it out than you'd save by losing an argument?
>> 
>> It sure will if it's the different between the argument being passed
>> in a register vs. on the stack.
> 
> I have a patch to replace u32 mark with an sk_buff. The mark is in the 
> sk_buff already, and so is the secpath field I need. Would that be 
> acceptable? I can hold off until the merge window is over.

Sounds good, and yes please wait until after the merge window.
