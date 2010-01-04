From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: make sure ethernet header is in transmit skb
Date: Sun, 03 Jan 2010 21:32:58 -0800 (PST)
Message-ID: <20100103.213258.263977883.davem@davemloft.net>
References: <20091226140544.5600b3d1@nehalam>
	<20091226.194418.229766965.davem@davemloft.net>
	<20091226.201107.35060733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbreuer@majjas.com, akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40706
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750738Ab0ADFcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:32:55 -0500
In-Reply-To: <20091226.201107.35060733.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 26 Dec 2009 20:11:07 -0800 (PST)

> From: David Miller <davem@davemloft.net>
> Date: Sat, 26 Dec 2009 19:44:18 -0800 (PST)
> 
>> From: Stephen Hemminger <shemminger@linux-foundation.org>
>> Date: Sat, 26 Dec 2009 14:05:44 -0800
>> 
>>> Other drivers may have same problem, I really think this ought
>>> to be done at higher level.
>> 
>> I tend to agree with you, and I thought we had handled all
>> cases.  Let's simply make AF_PACKET linearize the link
>> level header before sending things out to the transmit path.
>> 
>> I can work on this if you want.
> 
> Actually Stephen, I took a look and I can't see how AF_PACKET
> can create this situation.
> 
> It always copies into the linear area of the SKB it allocates
> for sendmsg() processing.  Whether the data comes from sendmsg
> data or the mmap() ring buffer.

Stephen can you get a backtrace of the code path which triggers
this?  I want to fix it at a higher level too, but I can't
do that until I know where it actually happens.

Thanks!
