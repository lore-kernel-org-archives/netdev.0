From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neighbour information dumping: some entries can be
 skipped
Date: Fri, 06 Feb 2009 00:52:13 -0800 (PST)
Message-ID: <20090206.005213.113322453.davem@davemloft.net>
References: <4e0db5bc0902051837o75eeb554h592a03f9506fd9b1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: gk@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47669
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752090AbZBFIwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 03:52:17 -0500
In-Reply-To: <4e0db5bc0902051837o75eeb554h592a03f9506fd9b1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gautam Kachroo <gk@aristanetworks.com>
Date: Thu, 5 Feb 2009 18:37:38 -0800

> neightbl_dump_info and neigh_dump_table  can skip entries if the
> *fill*info functions return an error. This results in an incomplete
> dump ((invoked by netlink requests for RTM_GETNEIGHTBL or
> RTM_GETNEIGH)
> 
> nidx and idx should not be incremented if the current entry was not
> placed in the output buffer
> 
> Signed-off-by: Gautam Kachroo <gk@aristanetworks.com>

Patch applied, thank you.
