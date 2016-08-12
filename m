From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/4] flow_dissector: Get vlan info from
 skb->vlan_tci instead of skb->data
Date: Fri, 12 Aug 2016 08:24:40 +0200
Message-ID: <20160812062440.GC1841@nanopsycho.orion>
References: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
 <1470835943-9042-2-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35902 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbcHLGYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 02:24:43 -0400
Received: by mail-wm0-f66.google.com with SMTP id i138so1048791wmf.3
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 23:24:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1470835943-9042-2-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 10, 2016 at 03:32:20PM CEST, hadarh@mellanox.com wrote:
>Early in the datapath skb_vlan_untag function is called, stripped
>the vlan from the skb and set skb->vlan_tci and skb->vlan_proto fields.
>
>The current dissection doesn't handle vlan packets correctly.  Vlan
>doesn't exist in skb->data anymore when applying flow dissection on the
>skb, fix that.
>
>Fixes: 0744dd00c1b1 ('net: introduce skb_flow_dissect()')
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
