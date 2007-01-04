From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH  v4 01/13] Linux RDMA Core Changes
Date: Thu, 04 Jan 2007 08:07:10 -0600
Message-ID: <1167919630.3071.8.camel@stevo-desktop>
References: <1167851839.4187.36.camel@stevo-desktop>
	 <20070103193324.GD29003@mellanox.co.il>
	 <1167855618.4187.65.camel@stevo-desktop>
	 <1167859320.4187.81.camel@stevo-desktop>
	 <20070104050722.GA9900@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:38076 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964863AbXADOHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 09:07:12 -0500
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
In-Reply-To: <20070104050722.GA9900@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-01-04 at 07:07 +0200, Michael S. Tsirkin wrote:
> > If you think I should not add the udata parameter to the req_notify_cq()
> > provider verb, then I can rework the chelsio driver:
> > 
> > 1) at cq creation time, pass the virtual address of the u32 used by the
> > library to track the current cq index.  That way the chelsio kernel
> > driver can save the address in its kernel cq context for later use.
> > 
> > 2) change chelsio's req_notify_cq() to copy in the current cq index
> > value directly for rearming.
> > 
> > This puts all the burden on the chelsio driver, which is apparently the
> > only one that needs this functionality.  
> 
> Good thinking, I haven't thought of this approach.
> 
> This way there won't be any API/core changes and no changes to
> other low level drivers, correct? And for chelsio, there's no overhead
> as compared to code you posted.
> 
> Sounds good.
> 

I still want to hear from Roland on this before I go to the effort of
reworking all this...


Steve.

