From: Roland Dreier <rdreier@cisco.com>
Subject: Re: InfiniBand/RDMA merge plans for 2.6.24
Date: Fri, 14 Sep 2007 09:09:13 -0700
Message-ID: <adazlzpjkk6.fsf@cisco.com>
References: <OFAE678C61.64C333F1-ON87257355.007A0B34-88257355.004E6EAD@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Shirley Ma <xma@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:20757 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754077AbXINQJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 12:09:14 -0400
In-Reply-To: <OFAE678C61.64C333F1-ON87257355.007A0B34-88257355.004E6EAD@us.ibm.com> (Shirley Ma's message of "Thu, 13 Sep 2007 15:16:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > The patch is just needed to pick up broadcast MTU size instead of hard
 > coding 2K right now. SKB allocation shouldn't be different with Ethernet
 > Jambo Frame and IPoIB-CM which 64K MTU. I don't understand why it's
 > different. Could you please explain this?

It's exactly the same problem as ethernet jumbo frames.  A web search
for '"order 1" failure e1000' might be interesting.

IPoIB CM handles this properly by gathering together single pages in
skbs' fragment lists.

 - R.
