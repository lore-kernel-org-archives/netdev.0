From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V2 2/5] flow_dissector: Get vlan priority in
 addition to vlan id
Date: Thu, 18 Aug 2016 09:25:24 +0200
Message-ID: <20160818072524.GC1953@nanopsycho>
References: <1471430174-27740-1-git-send-email-hadarh@mellanox.com>
 <1471430174-27740-3-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <tom@herbertland.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35658 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbcHRHZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 03:25:27 -0400
Received: by mail-wm0-f65.google.com with SMTP id i5so3558197wmg.2
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 00:25:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1471430174-27740-3-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 17, 2016 at 12:36:11PM CEST, hadarh@mellanox.com wrote:
>Add vlan priority check to the flow dissector by adding new flow
>dissector struct, flow_dissector_key_vlan which includes vlan tag
>fields.
>
>vlan_id and flow_label fields were under the same struct
>(flow_dissector_key_tags). It was a convenient setting since struct
>flow_dissector_key_tags is used by struct flow_keys and by setting
>vlan_id and flow_label under the same struct, we get precisely 24 or 48
>bytes in flow_keys from flow_dissector_key_basic.
>
>Now, when adding vlan priority support, the code will be cleaner if
>flow_label and vlan tag won't be under the same struct anymore.
>
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
