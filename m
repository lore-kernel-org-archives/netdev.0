From: Christoph Lameter <cl@linux.com>
Subject: Re: [IPoIB] Identify multicast packets and fix IGMP breakage V3
Date: Thu, 26 Aug 2010 21:24:15 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1008262123410.29657@router.home>
References: <alpine.DEB.2.00.1008261825490.26351@router.home> <20100826234342.GA24333@obsidianresearch.com> <alpine.DEB.2.00.1008261856090.29657@router.home> <20100826.170716.68143372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgunthorpe@obsidianresearch.com, rdreier@cisco.com,
	linux-rdma@vger.kernel.org, ogerlitz@voltaire.com,
	yosefe@voltaire.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.prem.mail.ac4.yahoo.com ([76.13.13.43]:34715 "HELO
	smtp104.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752669Ab0H0CYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 22:24:18 -0400
In-Reply-To: <20100826.170716.68143372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 26 Aug 2010, David Miller wrote:

> The highest cost is bringing in that packet header's cache line, which
> you've already done by reading the byte and checking for 0xff.

And then you need to bring in the cacheline of the broadcast address....
These are pretty long byte strings in the IB case.

