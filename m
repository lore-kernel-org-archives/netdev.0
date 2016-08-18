From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V2 1/5] flow_dissector: For stripped vlan, get
 vlan info from skb->vlan_tci
Date: Thu, 18 Aug 2016 09:24:59 +0200
Message-ID: <20160818072459.GB1953@nanopsycho>
References: <1471430174-27740-1-git-send-email-hadarh@mellanox.com>
 <1471430174-27740-2-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <tom@herbertland.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33054 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbcHRHZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 03:25:03 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so3594847wme.0
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 00:25:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1471430174-27740-2-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 17, 2016 at 12:36:10PM CEST, hadarh@mellanox.com wrote:
>Early in the datapath skb_vlan_untag function is called, stripped
>the vlan from the skb and set skb->vlan_tci and skb->vlan_proto fields.
>
>The current dissection doesn't handle stripped vlan packets correctly.
>In some flows, vlan doesn't exist in skb->data anymore when applying
>flow dissection on the skb, fix that.
>
>In case vlan info wasn't stripped before applying flow_dissector (RPS
>flow for example), or in case of skb with multiple vlans (e.g. 802.1ad),
>get the vlan info from skb->data. The flow_dissector correctly skips
>any number of vlans and stores only the first level vlan.
>
>Fixes: 0744dd00c1b1 ('net: introduce skb_flow_dissect()')
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
