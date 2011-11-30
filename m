From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: inherit listener congestion control for
 passive cnx
Date: Wed, 30 Nov 2011 16:56:16 -0500 (EST)
Message-ID: <20111130.165616.1052827966653115513.davem@davemloft.net>
References: <1322631613.2596.70.camel@edumazet-laptop>
	<1322650961.2403.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4ED6A019.2040708@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, ycheng@google.com,
	shemminger@vyatta.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab1K3V4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 16:56:32 -0500
In-Reply-To: <4ED6A019.2040708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 30 Nov 2011 13:28:57 -0800

>>
>> Rick Jones reported that TCP_CONGESTION sockopt performed on a
>> listener
>> was ignored for its children sockets : right after accept() the
>> congestion control for new socket is the system default one.
>>
>> This seems an oversight of the initial design (quoted from Stephen)
>>
>> Based on prior investigation and patch from Rick.
>>
>> Reported-by: Rick Jones<rick.jones2@hp.com>
>> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
>> CC: Stephen Hemminger<shemminger@vyatta.com>
>> CC: Yuchung Cheng<ycheng@google.com>
> 
> Tested-by: Rick Jones <rick.jones2@hp.com>

Applied, thanks everyone.
