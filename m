From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bridge: check the length of skb after
 nf_bridge_maybe_copy_header()
Date: Thu, 06 Jan 2011 11:33:20 -0800 (PST)
Message-ID: <20110106.113320.28809548.davem@davemloft.net>
References: <20110103101533.3f98b311@nehalam>
	<20110103.121336.212692696.davem@davemloft.net>
	<AANLkTikb+o2tXg0uU92Q9foVqX2P49dhJX+umLX=Nhfn@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45274
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752644Ab1AFTcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 14:32:48 -0500
In-Reply-To: <AANLkTikb+o2tXg0uU92Q9foVqX2P49dhJX+umLX=Nhfn@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 5 Jan 2011 21:37:28 +0800

> On Tue, Jan 4, 2011 at 4:13 AM, David Miller <davem@davemloft.net> wrote:
>> From: Stephen Hemminger <shemminger@linux-foundation.org>
>>>
>>> Because PPPOE happens afterwards and is not part the calculation.
>>> The check should be moved until after skb has reached final form.
>>
>> That works for me.
>>
> 
> So, is my patch acceptable?

Yes, I've applied it, thank you.
