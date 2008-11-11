From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: fix warn_on reload after phy_id error
Date: Tue, 11 Nov 2008 03:31:10 -0500
Message-ID: <491942CE.4010604@garzik.org>
References: <20081108002739.17508.60954.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36956 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334AbYKKIbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 03:31:13 -0500
In-Reply-To: <20081108002739.17508.60954.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> If the driver fails to initialize the first time due to the failure in the
> phy_id check the kernel triggers a warn_on on the second try to load the
> driver because the driver did not free the msi/x resources in the first
> load because of the previous failure in phy_id check.

Is that all one sentence?  Can I buy a comma or semi-colon, Pat?  :)

More seriously, this description is not very helpful.  A good 
description precisely outlines the _solution_ ("fix msi/x resource 
leak"), perhaps with a bit of concise problem description ("failure to 
free msi/x resources").

Your description focuses mostly on what the user/tester experiences and 
observes, whereas in a changeset description the most important thing to 
communicate is to describe the engineering change to the driver (proper 
release of resources).

	Jeff




