From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: [PATCH  v4 01/13] Linux RDMA Core Changes
Date: Thu, 4 Jan 2007 07:07:22 +0200
Message-ID: <20070104050722.GA9900@mellanox.co.il>
References: <1167851839.4187.36.camel@stevo-desktop> <20070103193324.GD29003@mellanox.co.il> <1167855618.4187.65.camel@stevo-desktop> <1167859320.4187.81.camel@stevo-desktop>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c11o146.mxlogic.net ([208.65.145.69]:59698 "EHLO
	p02c11o146.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932261AbXADFOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 00:14:41 -0500
To: Steve Wise <swise@opengridcomputing.com>
Content-Disposition: inline
In-Reply-To: <1167859320.4187.81.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If you think I should not add the udata parameter to the req_notify_cq()
> provider verb, then I can rework the chelsio driver:
> 
> 1) at cq creation time, pass the virtual address of the u32 used by the
> library to track the current cq index.  That way the chelsio kernel
> driver can save the address in its kernel cq context for later use.
> 
> 2) change chelsio's req_notify_cq() to copy in the current cq index
> value directly for rearming.
> 
> This puts all the burden on the chelsio driver, which is apparently the
> only one that needs this functionality.  

Good thinking, I haven't thought of this approach.

This way there won't be any API/core changes and no changes to
other low level drivers, correct? And for chelsio, there's no overhead
as compared to code you posted.

Sounds good.

-- 
MST
