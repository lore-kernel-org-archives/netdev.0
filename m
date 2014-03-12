From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 05/13] igb: Add support for debugfs
Date: Wed, 12 Mar 2014 15:46:50 -0400 (EDT)
Message-ID: <20140312.154650.1047434627285395570.davem@davemloft.net>
References: <1394603618-1044-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJZOPZ+TtFRjeA=9WZMhONSd65HZwMizf732W7oe-HJ=E0MBvg@mail.gmail.com>
	<9BBC4E0CF881AA4299206E2E1412B6264FAB3870@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: or.gerlitz@gmail.com, jeffrey.t.kirsher@intel.com,
	gospo@redhat.com, netdev@vger.kernel.org, sassmann@redhat.com,
	hayja@mail.uc.edu, amirv@mellanox.com, yevgenyp@mellanox.com
To: carolyn.wyborny@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbaCLTqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 15:46:52 -0400
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B6264FAB3870@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Date: Wed, 12 Mar 2014 16:35:49 +0000

> Josh and I tried very hard to not reimplement anything already
> available in some other tool or mechanism and used the examples we
> already have for this in our other drivers.  That being said, we'll
> abide and follow any clear criteria provided.

I don't think what's being done here is appropriate.

ethtool can provide the extended statistics.

We already have a way to dump registers in ethtool as well.  If you
want to add fine-grained register read support and write support, that
would be a nice addition to ethtool.
