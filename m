From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sysfs: add attribute to indicate hw address
 assignment type
Date: Sat, 24 Jul 2010 20:50:29 -0700 (PDT)
Message-ID: <20100724.205029.183042907.davem@davemloft.net>
References: <4C483E8D.4080300@redhat.com>
	<1279807643.2104.1.camel@achroite.uk.solarflarecom.com>
	<4C485A0C.7020500@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, abadea@ixiacom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, leedom@chelsio.com, harald@redhat.com
To: sassmann@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44489
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751162Ab0GYDuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 23:50:13 -0400
In-Reply-To: <4C485A0C.7020500@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@redhat.com>
Date: Thu, 22 Jul 2010 16:47:40 +0200

> On 22.07.2010 16:07, Ben Hutchings wrote:
>> On Thu, 2010-07-22 at 14:50 +0200, Stefan Assmann wrote:
>>> On 21.07.2010 15:54, Ben Hutchings wrote:
>>>> On Wed, 2010-07-21 at 10:10 +0200, Stefan Assmann wrote:
>>>>> I put Alex' idea into code for further discussion, keeping the names
>>>>> mentioned here until we agree on the scope of this attribute. When we
>>>>> have settled I'll post a patch with proper patch description.
>>>> [...]
>>>>
>>>> Just a little nitpick: I think it would be clearer to use a more
>>>> specific term like 'address source' or 'address assignment type' rather
>>>> than 'address type'.
>>>
>>> Here's a proposal for the final patch.
>> 
>> Looks good, but...
 ...
>> ...why '|=' and not '='?
> 
> The intention is to use addr_assign_type as a bit field.
> 
> Okay it it might not make too much sense to 'steal' a random MAC
> address but in case we add more types later it might get useful.

I think the patch is good enough to go into net-next-2.6 as-is, anything
remaining is a refinement or one sort or another.

So applied to net-next-2.6, thanks.
