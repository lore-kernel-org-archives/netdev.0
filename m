From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][VLAN] Merge tree equal tails in vlan_skb_recv
Date: Wed, 09 Jan 2008 19:42:37 +0100
Message-ID: <4785159D.9090105@trash.net>
References: <47591ECF.2020707@openvz.org> <47591F9F.1020607@trash.net> <478482A7.1040505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65119 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755AbYAISqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 13:46:51 -0500
In-Reply-To: <478482A7.1040505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Hi, Patrick.
> 
>> Pavel Emelyanov wrote:
>>> There are tree paths in it, that set the skb->proto and then
>>> perform common receive manipulations (basically call netif_rx()).
>>>
>>> I think, that we can make this code flow easier to understand
>>> by introducing the vlan_set_encap_proto() function (I hope the 
>>> name is good) to setup the skb proto and merge the paths calling 
>>> netif_rx() together.
>>>
>>> Surprisingly, but gcc detects this thing and merges these paths
>>> by itself, so this patch doesn't make the vlan module smaller.
>>
>> I already have something similar queued, but your patch is a nice
>> cleanup on top. I'll merge it into my tree and send it out after
>> some testing, hopefully today.
>>
> 
> What are your plans about this patch? Should I resubmit this one?


Sorry, I'm pretty backlogged from Christmas, but I have your patch
queued and hope to catch up until the end of this week.
