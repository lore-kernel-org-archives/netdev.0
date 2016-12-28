From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net/sched: cls_flower: Fix missing addr_type in
 classify
Date: Wed, 28 Dec 2016 16:48:55 +0100
Message-ID: <20161228154855.GA1839@nanopsycho.orion>
References: <1482929687-20159-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36121 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750956AbcL1Ptj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 10:49:39 -0500
Received: by mail-wm0-f66.google.com with SMTP id m203so62424955wma.3
        for <netdev@vger.kernel.org>; Wed, 28 Dec 2016 07:48:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1482929687-20159-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 28, 2016 at 01:54:47PM CET, paulb@mellanox.com wrote:
>Since we now use a non zero mask on addr_type, we are matching on its
>value (IPV4/IPV6). So before this fix, matching on enc_src_ip/enc_dst_ip
>failed in SW/classify path since its value was zero.
>This patch sets the proper value of addr_type for encapsulated packets.
>
>Fixes: 970bfcd09791 ('net/sched: cls_flower: Use mask for addr_type')
>Signed-off-by: Paul Blakey <paulb@mellanox.com>
>Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
