From: David Miller <davem@davemloft.net>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Tue, 10 Oct 2006 20:50:49 -0700 (PDT)
Message-ID: <20061010.205049.132929620.davem@davemloft.net>
References: <adak637bjs3.fsf@cisco.com>
	<20061010.204528.90823856.davem@davemloft.net>
	<adafydvbjgq.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@mellanox.co.il, shemminger@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org, rolandd@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47043
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030783AbWJKDuq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 23:50:46 -0400
To: rdreier@cisco.com
In-Reply-To: <adafydvbjgq.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 10 Oct 2006 20:49:09 -0700

>     David> non-sendfile() paths will generate big packets just fine,
>     David> as long as the application is providing that much data.
> 
> OK, cool.  Will the big packets be non-linear skbs?

If you had SG enabled (and thus checksumming offload too) then yes
you'll get a non-linear SKB.  Otherwise, without SG, you'll get a
fully linear SKB.
