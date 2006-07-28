From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Fri, 28 Jul 2006 16:14:50 -0700
Message-ID: <44CA9A6A.2030707@candelatech.com>
References: <20060728221455.GA25610@walrus.eth1.org>	<44CA8AF1.3020408@candelatech.com>	<20060728225859.GC25610@walrus.eth1.org> <20060728.155551.57160395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: christophe.devriese@eth1.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:24965 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1161365AbWG1XO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 19:14:56 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060728.155551.57160395.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Christophe Devriese <christophe.devriese@eth1.org>
> Date: Sat, 29 Jul 2006 00:58:59 +0200
> 
> 
>>On Fri, Jul 28, 2006 at 03:08:49PM -0700, Ben Greear wrote:
>>
>>>Christophe Devriese wrote:
>>>
>>>>On Fri, Jul 28, 2006 at 02:55:17PM -0700, Ben Greear wrote:
>>>>
>>>>
>>>>>Christophe Devriese wrote:
>>>>>
>>>>>
>>>>>>I basically move the skb_bond method into if_bonding.h, include that file
>>>>>>in if_vlan ( and call it from the vlan forwarding path, and the netif_rx
>>>>>>routine ). 
>>>>>>
>>>>>>Somehow this patch is very incomplete. Let me try again.
>>>>>
>>>>>The patch looks sane this time.
>>>>>
>>>>>The skb_bond method assigns skb->dev when it does the 'keep',
>>>>>but the VLAN code immediately over-writes the skb->dev when
>>>>>searching for the vlan device.
>>>>>
>>>>>What is the purpose of assinging skb->dev to the master device?
>>>>
>>>>
>>>>I don't know. The method was only moved by this patch, not changed. The
>>>>contents of the method are exactly what they are in
>>>>linux-2.6.17.7/net/core/dev.c 
>>>>
>>>>I assume it has something to do with the other bonding methods.
>>>
>>>Ok, I don't know much about the bonding logic.  Looks OK to me.
>>
>>Will you sign-off on it then ? Or how do I get this applied ?
> 
> 
> I'll apply this over the weekend unless I spot some problem
> with it, thanks.
> 
> A sign off from Ben would be nice too :)

I don't see any problems with the patch.  The skb->dev
assignment is redundant for the VLAN path, but may be useful
elsewhere.  At any rate, it doesn't seem like it would hurt
anything.

Signed-off-by Ben Greear <greearb@candelatech.com>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

