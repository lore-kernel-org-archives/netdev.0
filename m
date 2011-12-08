From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] add netpoll support for 802.1q vlans
Date: Thu, 08 Dec 2011 11:50:55 -0500 (EST)
Message-ID: <20111208.115055.193423469660678623.davem@davemloft.net>
References: <20111207010424.GA16496@kvack.org>
	<20111208.000730.63159506168958262.davem@davemloft.net>
	<20111208153558.GE30652@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158Ab1LHQu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 11:50:59 -0500
In-Reply-To: <20111208153558.GE30652@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Thu, 8 Dec 2011 10:35:58 -0500

> On Thu, Dec 08, 2011 at 12:07:30AM -0500, David Miller wrote:
>> From: Benjamin LaHaise <bcrl@kvack.org>
>> Date: Tue, 6 Dec 2011 20:04:24 -0500
>> 
>> > Add netpoll support to 802.1q vlan devices.  Based on the netpoll support 
>> > in the bridging code.  Tested on a forced_eth device with netconsole.
>> > 
>> > Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
>> 
>> Bridging doesn't try to invoke a downstream netpoll operation at all,
>> and neither should you.
> 
> Please have a look at net/bridge/br_device.c:br_netpoll_setup() which is 
> where the approach came from.

I did and I'm not talking about that part, I'm talking about the
part where you invoke the downstream device's netpoll operation.

Did you even read my entire sentence, or did you just let the
knee jerk reaction set in before you got to the end?

> Getting netconsole over vlans working is a requirement for those of us 

What does this have to do with anything?  I never made any even remote
argument that this change wasn't useful.  I said only that you
implemented it incorrectly.

Take a deep breath and just implement the patch correctly.
