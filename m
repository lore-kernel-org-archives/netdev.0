From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 2/2] tc: m_vlan: Add priority option to push
 vlan action
Date: Mon, 22 Aug 2016 13:07:14 +0200
Message-ID: <20160822110714.GB1970@nanopsycho>
References: <1471861494-8299-1-git-send-email-hadarh@mellanox.com>
 <1471861494-8299-3-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35581 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752548AbcHVLHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:07:41 -0400
Received: by mail-wm0-f66.google.com with SMTP id i5so12921833wmg.2
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 04:07:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1471861494-8299-3-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 22, 2016 at 12:24:54PM CEST, hadarh@mellanox.com wrote:
>The current vlan push action supports only vid and protocol options.
>Add priority option.
>
>Example script that adds vlan push action with vid and priority:
>
>tc filter add dev veth0 protocol ip parent ffff: \
>	flower \
>	indev veth0 \
>	action vlan push id 100 priority 5
>
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
