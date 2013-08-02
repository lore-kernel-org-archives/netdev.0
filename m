From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: mlx5: fix sizeof usage in health_care's
 reg_handler
Date: Fri, 02 Aug 2013 15:11:32 -0700 (PDT)
Message-ID: <20130802.151132.539136654627638979.davem@davemloft.net>
References: <1375438577-30933-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab3HBWLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 18:11:33 -0400
In-Reply-To: <1375438577-30933-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri,  2 Aug 2013 12:16:17 +0200

> Therefore, I strongly assume sizeof(*health->health) is being meant
> to be passed as an argument. Interestingly, there are actually no
> in-tree users of mlx5_[un]register_health_report_handler(), but some
> debugging modules might want to know the correct size instead.

I want these hooks and infrastructure removed immediately.

If there are no in-tree users there is no reason for them to
exist at all.

Thanks.
