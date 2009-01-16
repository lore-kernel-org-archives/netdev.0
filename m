From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2.6.28] cxgb3 - Fix LRO misalignment
Date: Fri, 16 Jan 2009 11:05:50 -0800
Message-ID: <4970DA8E.6030105@chelsio.com>
References: <20090116004829.7437.52798.stgit@speedy5> <496FE973.1060106@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>,
	Casey Leedom <leedom@chelsio.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:24217 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084AbZAPTGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 14:06:07 -0500
In-Reply-To: <496FE973.1060106@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> Divy Le Ray wrote:
>   
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> The lro manager's frag_align_pad setting was missing,
>> leading to misaligned access to the skb passed up
>> to the stack.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>>     
>
> I have tried this in a tree I have, and where I was once seeing unaligned access 
> messages on an ia64 system with LRO enabled, now I see none.
>
> Tested-by: Rick Jones <rick.jones2@hp.com>
>
> rick jones
>
>   
Hi Dave,

The patch is intended for 2.6.29, not 2.6.28 as the subject mistakenly 
states.

Cheers,
Divy
