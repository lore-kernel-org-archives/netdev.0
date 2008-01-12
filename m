From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 5/7] netxen: fix race in interrupt / napi
Date: Sat, 12 Jan 2008 17:38:03 -0500
Message-ID: <4789414B.40800@garzik.org>
References: <20071226182352.704678179@netxen.com> <20071226182927.778015972@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40439 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757568AbYALWiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 17:38:04 -0500
In-Reply-To: <20071226182927.778015972@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

patch conflicted with

commit 1706287f6eb58726a9a0e5cbbde87f49757615e3
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Jan 7 20:51:29 2008 -0800

     [NETXEN]: Fix ->poll() done logic.

     If work_done >= budget we should always elide the NAPI
     completion.

     Signed-off-by: David S. Miller <davem@davemloft.net>
