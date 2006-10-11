From: David Miller <davem@davemloft.net>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Tue, 10 Oct 2006 20:45:28 -0700 (PDT)
Message-ID: <20061010.204528.90823856.davem@davemloft.net>
References: <adar6xfbk6d.fsf@cisco.com>
	<20061010.203624.91207079.davem@davemloft.net>
	<adak637bjs3.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@mellanox.co.il, shemminger@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org, rolandd@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14027
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030781AbWJKDpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 23:45:25 -0400
To: rdreier@cisco.com
In-Reply-To: <adak637bjs3.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 10 Oct 2006 20:42:20 -0700

> On the other hand I'm not sure how useful such a netdevice would be --
> will non-sendfile() paths generate big packets even if the MTU is 64KB?

non-sendfile() paths will generate big packets just fine, as long
as the application is providing that much data.
