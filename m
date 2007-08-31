From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
 take 2
Date: Fri, 31 Aug 2007 10:19:10 -0700
Message-ID: <46D84D8E.9020705@hp.com>
References: <200708310009.RAA04175@tardy.cup.hp.com>	<20070830.173912.79067694.davem@davemloft.net>	<46D769C1.8090808@hp.com> <46D79E91.2040004@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:57051 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965394AbXHaRTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 13:19:17 -0400
In-Reply-To: <46D79E91.2040004@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> Rick Jones wrote:
> 
>> Like I said the consumers of this are a triffle well, "anxious" :)
> 
> 
> Just curious, did you or this customer try with F-RTO enabled?  Or is 
> this case you're dealing with truly hopeless?

F-RTO was mentioned to the customer and I'm awaiting their response as 
to its efficacy in their situation.  Everything I've seen thusfar is 
leading me to believe that we'll still need a higher than 200 
millisecond minimum rto though.

rick
