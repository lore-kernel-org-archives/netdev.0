From: David Miller <davem@davemloft.net>
Subject: Re: A SACK block to the left of the ACK? (with ptr to raw trace)
Date: Fri, 09 May 2014 15:18:03 -0400 (EDT)
Message-ID: <20140509.151803.557587813948439688.davem@davemloft.net>
References: <536D11A0.6050400@hp.com>
	<CABrhC0kFEMOR7LTMFS4ktEgW0w+1v_vSP8xU_Vh8+iKmtEUb4A@mail.gmail.com>
	<536D1D87.3060706@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009AbaEITSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 15:18:06 -0400
In-Reply-To: <536D1D87.3060706@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 09 May 2014 11:25:11 -0700

> On 05/09/2014 11:21 AM, John Heffner wrote:
>> I didn't actually look at the trace, but offhand this sounds like
>> D-SACK. (http://www.ietf.org/rfc/rfc2883.txt)
> 
> Thanks for the gentle tap with the clue-bat :)

Indeed, it's probably a D-SACK and can be used to let the sender
know when a retransmit turned out to be spurious.
