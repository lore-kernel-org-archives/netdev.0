From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH][VLAN] Merge tree equal tails in vlan_skb_recv
Date: Wed, 09 Jan 2008 11:15:35 +0300
Message-ID: <478482A7.1040505@openvz.org>
References: <47591ECF.2020707@openvz.org> <47591F9F.1020607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55704 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750718AbYAIIPY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 03:15:24 -0500
In-Reply-To: <47591F9F.1020607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Patrick.

> Pavel Emelyanov wrote:
>> There are tree paths in it, that set the skb->proto and then
>> perform common receive manipulations (basically call netif_rx()).
>>
>> I think, that we can make this code flow easier to understand
>> by introducing the vlan_set_encap_proto() function (I hope the 
>> name is good) to setup the skb proto and merge the paths calling 
>> netif_rx() together.
>>
>> Surprisingly, but gcc detects this thing and merges these paths
>> by itself, so this patch doesn't make the vlan module smaller.
> 
> 
> I already have something similar queued, but your patch is a nice
> cleanup on top. I'll merge it into my tree and send it out after
> some testing, hopefully today.
> 

What are your plans about this patch? Should I resubmit this one?

Thanks,
Pavel
