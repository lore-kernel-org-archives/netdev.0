From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: [PATCH  v4 01/13] Linux RDMA Core Changes
Date: Sat, 6 Jan 2007 19:34:40 +0200
Message-ID: <20070106173439.GC26997@mellanox.co.il>
References: <8A71B368A89016469F72CD08050AD334F3BE50@maui.asicdesigners.com>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise@opengridcomputing.com>,
	Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c11o143.mxlogic.net ([208.65.145.66]:50616 "EHLO
	p02c11o143.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbXAFReU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 12:34:20 -0500
To: Felix Marti <felix@chelsio.com>
Content-Disposition: inline
In-Reply-To: <8A71B368A89016469F72CD08050AD334F3BE50@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> [Felix Marti] In addition, is arming the CQ really in the performance
> path? - Don't apps poll the CQ as long as there are pending CQEs and
> only arm the CQ for notification once there is nothing left to do? If
> this is the case, it would mean that we waste a few cycles 'idle'
> cycles.

Applications such as IPoIB might queue up packets, then ARM the CQ,
and only then they are processed by the upper layers in the stack.
So arming the CQ is on hot datapath.

-- 
MST
