From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 18:27:33 +0200
Message-ID: <4832FBF5.1000305@trash.net>
References: <4832E223.7020206@trash.net> <20080520144822.GR28241@solarflare.com> <4832E55E.2030009@trash.net> <4832F260.5000104@candelatech.com> <20080520162011.GT28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44188 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761679AbYETQ1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 12:27:36 -0400
In-Reply-To: <20080520162011.GT28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Ben Greear wrote:
>> Patrick McHardy wrote:
>>> Ben Hutchings wrote:
>>>> I really don't think it's a good idea to move around existing flags.  
>>>> How
>>>> about stealing some of the unused high-order bits of NETIF_F_GSO_MASK
>>>> instead?
>>>
>>> Mhh it doesn't really belong there. Whats the problem with
>>> moving these bits? They are only used internally (and use
>>> up too much space anyway).
>> I've been running with it shifted to 24 on 2.6.25 with no problems.   If 
>> no one else objects, I'd prefer it shifted all the way
>> to 24 to make room for more flags w/out additional changes in the 
>> shiftage later...
> 
> I would certainly be happy to see NETIF_F_GSO_MASK narrowed.  It's just a
> question of whether the low-order or high-order bits are removed.  My
> instinct is not to change the existing assigned flags if it's not really
> necessary.  They are exposed through /sys/class/net/ even if the flag
> names aren't part of the user-land headers.


I don't really care which bits exactly are used, so sure, I'll
update it before sending a final patch. But frankly, these bits
shouldn't have been exported through sysfs in the first place.


