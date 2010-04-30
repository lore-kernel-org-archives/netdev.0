From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: Stay in NAPI as long as there's work
Date: Fri, 30 Apr 2010 16:17:46 -0700 (PDT)
Message-ID: <20100430.161746.73666749.davem@davemloft.net>
References: <20100428112528.01277670@nehalam>
	<20100428.142534.57451492.davem@davemloft.net>
	<h2m65634d661004281656j9f29fc2btdec0d6bcbee20f35@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, joe@perches.com, netdev@vger.kernel.org,
	aabdulla@nvidia.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755894Ab0D3XRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 19:17:42 -0400
In-Reply-To: <h2m65634d661004281656j9f29fc2btdec0d6bcbee20f35@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 28 Apr 2010 16:56:30 -0700

> On Wed, Apr 28, 2010 at 2:25 PM, David Miller <davem@davemloft.net> wrote:
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Wed, 28 Apr 2010 11:25:28 -0700
>>
>>> The following does the same thing without the extra overhead
>>> of testing all the registers. It also handles the out of memory
>>> case.
>>>
>>> Compile tested only...
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> Tom can you test this version?
>>
> 
> Looks good.  406038 tps in my quick test which still is showing the
> benefits.  Thanks for cleaning this up Stephen!

Thanks for testing, applied, thanks everyone.
