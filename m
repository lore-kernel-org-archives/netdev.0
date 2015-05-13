From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 00/15] introduce programable flow dissector
 and cls_flower
Date: Wed, 13 May 2015 15:21:02 -0400 (EDT)
Message-ID: <20150513.152102.606157874586561609.davem@davemloft.net>
References: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, tom@herbertland.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933183AbbEMTVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 15:21:07 -0400
In-Reply-To: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 12 May 2015 14:56:06 +0200

> Per Davem's request, I prepared this patchset which introduces programmable
> flow dissector. For current users of flow_keys, there is a wrapper
> skb_flow_dissect_flow_keys which maintains the previous behaviour.
> For purposes of cls_flower, couple of new dissection keys were introduced.
> 
> Note that this dissector can be also eventually used by openvswitch code.
> 
> Also, as a next step, I plan to get rid of *skb_flow_get_ports(export)
> and *__skb_get_poff as their functionality can be now implemented by
> skb_flow_dissect as well.
> 
> v2->v3:
> - remove TCA_FLOWER_POLICE attr suggested by Jamal
> 
> v1->v2:
> - move __skb_tx_hash rather to dev.c as suggested by Alex

Ok, assuming this passes all of my build tests, I'll push this into
net-next.

I'm sure there will be some performance improvements possible, and I
hope you will look into making sure this new programmable classifier
is as light weight as possible.

Anyways, thanks a lot.
