From: David Miller <davem@davemloft.net>
Subject: Re: [net] e1000: Small packets may get corrupted during padding by
 HW
Date: Mon, 17 Sep 2012 12:31:13 -0400 (EDT)
Message-ID: <20120917.123113.458101376016589070.davem@davemloft.net>
References: <061C8A8601E8EE4CA8D8FD6990CEA89130DC20AA@ORSMSX102.amr.corp.intel.com>
	<50552FF1.5030708@intel.com>
	<061C8A8601E8EE4CA8D8FD6990CEA89130DC3631@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, mirqus@gmail.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: tushar.n.dave@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab2IQQbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 12:31:16 -0400
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA89130DC3631@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Date: Mon, 17 Sep 2012 07:33:12 +0000

> No because it is quite normal to have packet < ETH_ZLEN. e.g. ARP packets.

You're optimizing for ARP packets?  You're kidding right?
