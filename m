From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Tue, 09 Jan 2007 08:46:53 -0600
Message-ID: <1168354013.4628.14.camel@stevo-desktop>
References: <20061220124125.6286.17148.stgit@localhost.localdomain>
	 <45918CA4.3020601@garzik.org> <45A36C22.6010009@chelsio.com>
	 <45A36E59.30500@garzik.org> <1168349908.4628.3.camel@stevo-desktop>
	 <20070109135725.GF16107@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	openib-general <openib-general@openib.org>,
	linux-kernel@vger.kernel.org, Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:37706 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751181AbXAIOqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 09:46:53 -0500
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
In-Reply-To: <20070109135725.GF16107@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-09 at 15:57 +0200, Michael S. Tsirkin wrote:
> > We also need to decide on the ib_req_notify_cq() issue.  
> 
> Let's clarify - do you oppose doing copy_from_user from a fixed
> address passed in during setup?
> 

So far its been you and I arguing over this issue.  Before I go
implement it and retest everything, I'd like some indication that anyone
else thinks its the right thing to do vs adding the extra parameter to
ib_req_notify_cq().

> If OK with you, this seems the best way as it is the least controversial
> and least disruptive one.
> 

In the interest of expediting this I'll go implement it...

Steve.




