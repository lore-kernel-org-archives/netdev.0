From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/4] net_sched: flower: Add vlan support
Date: Fri, 12 Aug 2016 07:57:36 +0200
Message-ID: <20160812055736.GA1841@nanopsycho.orion>
References: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
 <1470835943-9042-4-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37611 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbcHLF5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 01:57:40 -0400
Received: by mail-wm0-f48.google.com with SMTP id i5so10774356wmg.0
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 22:57:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1470835943-9042-4-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 10, 2016 at 03:32:22PM CEST, hadarh@mellanox.com wrote:
>Enhance flower to support 802.1Q vlan protocol classification.
>Currently, the supported fields are vlan_id and vlan_priority.
>
>Example:
>
>	# add a flower filter with vlan id and priority classification
>	tc filter add dev ens4f0 protocol 802.1Q parent ffff: \
>		flower \
>		indev ens4f0 \
>		vlan_ethtype ipv4 \
>		vlan_id 100 \
>		vlan_prio 3 \
>	action vlan pop
>
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
