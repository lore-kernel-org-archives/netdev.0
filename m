From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: [ofa-general] [PATCH] RDMA/CMA: Implement rdma_resolve_ip retry
 enhancement.
Date: Wed, 19 Sep 2007 09:52:20 -0700
Message-ID: <46F153C4.2070008@ichips.intel.com>
References: <200709190022.l8J0MbWt024754@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: ggrundstrom@neteffect.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:51898 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753073AbXISQwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 12:52:25 -0400
In-Reply-To: <200709190022.l8J0MbWt024754@neteffect.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If an application is calling rdma_resolve_ip() and a status of -ENODATA is returned from addr_resolve_local/remote(), the timeout mechanism waits until the application's timeout occurs before rechecking the address resolution status; the application will wait until it's full timeout occurs.  This case is seen when the work thread call to process_req() is made before the arp packet is processed.

I don't understand the issue.  process_req() is invoked whenever a 
network event occurs, which rechecks all pending requests.

> This patch is in addition to Steve Wise's neigh_event_send patch to initiate neighbour discovery sent on 9/12/2007.

This patch looks unrelated to Steve's patch.  Can you clarify the 
relationship?

- Sean
