From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] net: dcbnl: remove redundant
 DCB_CAP_DCBX_STATIC bit
Date: Mon, 24 Jan 2011 15:19:22 -0800 (PST)
Message-ID: <20110124.151922.179947972.davem@davemloft.net>
References: <4D3D123F.40700@intel.com>
	<1295882871.25104.20.camel@lb-tlvb-shmulik.il.broadcom.com>
	<4D3DA050.3020006@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shmulikr@broadcom.com, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60043
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752541Ab1AXXSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:18:48 -0500
In-Reply-To: <4D3DA050.3020006@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 24 Jan 2011 07:52:48 -0800

> On 1/24/2011 7:27 AM, Shmulik Ravid wrote:
>> 
>> On Sun, 2011-01-23 at 21:46 -0800, John Fastabend wrote:
>>> On 1/23/2011 8:53 AM, Shmulik Ravid wrote:
>>>>
>>>> On Fri, 2011-01-21 at 18:52 -0800, John Fastabend wrote:
>>>>> On 1/21/2011 6:35 PM, John Fastabend wrote:
>>>>>> Remove redundant DCB_CAP_DCBX_STATIC bit in DCB capabilities
>>>>>>
>>>>>> Setting this bit indicates that no embedded DCBx engine is
>>>>>> present and the hardware can not be configured. This is the
>>>>>> same as having none of the DCB capability flags set or simply
>>>>>> not implementing the dcbnl ops at all.
>>>>>>
>>>>>> This patch removes this bit. The bit has not made a stable
>>>>>> release yet so removing it should not be an issue with
>>>>>> existing apps.
>>>>>>
>>>>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>>>>> CC: Shmulik Ravid <shmulikr@broadcom.com>
>>>>>> ---
>>>>>>
>>>>>
> 
> Dave, Please drop this patch sorry for the noise.

OK.
