From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Thu, 22 May 2008 20:03:02 +0200
Message-ID: <4835B556.4020308@trash.net>
References: <E1JyqZL-0005qz-00@gondolin.me.apana.org.au> <48344DAA.4060107@trash.net> <20080521233952.GA27138@gondor.apana.org.au> <D5C1322C3E673F459512FB59E0DDC329051F36F5@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43282 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661AbYEVSEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 14:04:46 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329051F36F5@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P wrote:
>>> I thought about this myself, my second idea was to add a mask for 
>>> feature bits to be propagated. Unless there is a need for 
>>>       
>> the driver 
>>     
>>> to determine them at runtime, thats slightly simpler. The 
>>>       
>> driver would 
>>     
>>> do:
>>>
>>> dev->vlan_features = NETIF_F_CSUM_ALL | ...
>>>
>>> What do you think about this?
>>>       
>> Yes that sounds great!
>>     
>
> The issue is how does the driver know how to pull those flags off the
> VLAN device when the parent has TSO or CSUM offload disabled?  The only
> way I could come up with it was in my original patch in the drivers to
> loop through the entire VLAN group array, and clear the flag on existing
> devices.
>   

Yes, thats also what my patch is doing. Not a big deal I guess,
we're doing that for all kinds of notifications already and
nobody ever complained.
