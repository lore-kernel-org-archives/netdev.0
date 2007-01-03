From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH  v4 01/13] Linux RDMA Core Changes
Date: Wed, 03 Jan 2007 09:06:02 -0600
Message-ID: <1167836762.4187.15.camel@stevo-desktop>
References: <1167836172.4187.9.camel@stevo-desktop>
	 <20070103150230.GP6019@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:56910 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750838AbXACPGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 10:06:05 -0500
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
In-Reply-To: <20070103150230.GP6019@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-03 at 17:02 +0200, Michael S. Tsirkin wrote:
> > I've run this code with mthca and didn't notice any performance
> > degradation, but I wasn't specifically measuring cq_poll overhead in a
> > tight loop...
> 
> We were speaking about ib_req_notify_cq here, actually, not cq poll.
> So what was tested?
> 

Sorry, I meant req_notify.  I didn't specifically measure the cost of
req_notify before and after this change.

I've been running the user mode perftest programs mainly.  



