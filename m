From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Tue, 9 Jan 2007 15:57:25 +0200
Message-ID: <20070109135725.GF16107@mellanox.co.il>
References: <20061220124125.6286.17148.stgit@localhost.localdomain> <45918CA4.3020601@garzik.org> <45A36C22.6010009@chelsio.com> <45A36E59.30500@garzik.org> <1168349908.4628.3.camel@stevo-desktop>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	openib-general <openib-general@openib.org>,
	linux-kernel@vger.kernel.org, Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dev.mellanox.co.il ([194.90.237.44]:36992 "EHLO
	dev.mellanox.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932092AbXAIOAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 09:00:04 -0500
To: Steve Wise <swise@opengridcomputing.com>
Content-Disposition: inline
In-Reply-To: <1168349908.4628.3.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We also need to decide on the ib_req_notify_cq() issue.  

Let's clarify - do you oppose doing copy_from_user from a fixed
address passed in during setup?

If OK with you, this seems the best way as it is the least controversial
and least disruptive one.

-- 
MST
