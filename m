From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 4/4] net_sched: act_vlan: Add priority option
Date: Fri, 12 Aug 2016 08:05:59 +0200
Message-ID: <20160812060559.GB1841@nanopsycho.orion>
References: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
 <1470835943-9042-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33618 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbcHLGYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 02:24:18 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so1069579wme.0
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 23:24:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1470835943-9042-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 10, 2016 at 03:32:23PM CEST, hadarh@mellanox.com wrote:
>The current vlan push action supports only vid and protocol options.
>Add priority option.
>
>Example script that adds vlan push action with vid and
>priority:
>
>tc filter add dev veth0 protocol ip parent ffff: \
>	   flower \
>	   	indev veth0 \
>	   action vlan push id 100 priority 5
>
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
