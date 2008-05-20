From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Wed, 21 May 2008 01:59:07 +0200
Message-ID: <483365CB.8010100@trash.net>
References: <4832E223.7020206@trash.net> <20080520180528.GU28241@solarflare.com> <48331914.7050501@trash.net> <D5C1322C3E673F459512FB59E0DDC329051AC9FE@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55100 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213AbYETX7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 19:59:07 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329051AC9FE@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P wrote:
>>> Shouldn't this mask the flags out of vlandev->features first?
>>>   
>> Yes, thanks.
>>>> +	dev->features = real_dev->features & (NETIF_F_TSO | 
>> NETIF_F_TSO6);
>>>>     
>>> This should also test the NETIF_F_VLAN_TSO flag and should copy the 
>>> NETIF_F_ALL_CSUM and NETIF_F_SG flags since TSO requires those (see
>>> register_netdevice() feature fix-up).  Peter pointed out that TX 
>>> checksum offload for VLANs might be available even without TSO; the 
>>> same goes for scatter-gather but I don't know whether it's 
>> worth adding a flag for that.
>>>   
>> Thanks, I added NETIF_F_SG to the VLAN TSO flags and added a 
>> NETIF_F_VLAN_CSUM flag for TX checksums. I didn't change 
>> GSO_SHIFT so far.
> 
> I've tested your latest patch with an in-house modified ixgbe driver,
> both with CSUM and TSO.  This patch works great for adding and removing
> the feature flags on demand.  Thanks for putting this together Patrick.
> 
> -PJ Waskiewicz
> <peter.p.waskiewicz.jr@intel.com>

Great, I didn't notice your email before I saw Dave already
applied it :) Thanks Peter.

