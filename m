From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Thu, 14 Aug 2008 15:23:00 -0700 (PDT)
Message-ID: <20080814.152300.127682912.davem@davemloft.net>
References: <48A08145.6060703@hp.com>
	<20080811.141254.165409473.davem@davemloft.net>
	<48A49985.10704@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, rdreier@cisco.com, jgarzik@pobox.com,
	swise@opengridcomputing.com, divy@chelsio.com, kxie@chelsio.com,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, dm@chelsio.com, lee@jasper.es
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56900
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751714AbYHNWW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 18:22:58 -0400
In-Reply-To: <48A49985.10704@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Thu, 14 Aug 2008 16:45:57 -0400

> Speaking of stateless data placement.  Assume you have a page or set
> of pages allocated by a network driver which contain exactly the data
> a block driver is interested in to fulfill a read request (eg, the NIC
> understands the protocol just well enough to split headers).  Is it
> possible in the block driver to simply replace the pages that are
> attached to the buf with pages allocated by the network driver?
> 
> It was my impression that the pages associated with a buf are in
> fairly magical states and that you cannot replace them.

This, if true, would be quite easy to rectify.
