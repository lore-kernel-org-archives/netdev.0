From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Always untag vlan-tagged traffic on input.
Date: Fri, 08 Aug 2014 10:37:43 -0700 (PDT)
Message-ID: <20140808.103743.1027471237079294169.davem@davemloft.net>
References: <1407423334-3422-1-git-send-email-vyasevic@redhat.com>
	<20140808152618.GC1878@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org, kaber@trash.net,
	nsujir@broadcom.com, mchan@broadcom.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbaHHRhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 13:37:45 -0400
In-Reply-To: <20140808152618.GC1878@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 8 Aug 2014 17:26:18 +0200

> Thu, Aug 07, 2014 at 04:55:34PM CEST, vyasevic@redhat.com wrote:
>>+struct sk_buff *skb_untag(struct sk_buff *skb)
> 
> I would suggest to rename this to "skb_vlan_untag" to make this clear.
> Other than that, the patch looks good to me.

Agreed.
