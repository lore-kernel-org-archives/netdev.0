From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet: checksum and ethtool
Date: Fri, 1 Jun 2007 18:06:12 -0500
Message-ID: <20070601230612.GO7298@austin.ibm.com>
References: <20070529172436.3cd60dcf@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:44001 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753166AbXFAXGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 19:06:13 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l51N6DJa028682
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 19:06:13 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l51N6Ceg529472
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 19:06:12 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l51N6CFm027183
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 19:06:12 -0400
Content-Disposition: inline
In-Reply-To: <20070529172436.3cd60dcf@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 29, 2007 at 05:24:36PM -0700, Stephen Hemminger wrote:
> It doesn't look like spidernet hardware can really checksum all protocols,
> the code looks like it does IPV4 only.  If so, it should use NETIF_F_IP_CSUM
> instead of NETIF_F_HW_CSUM.
> 
> The driver doesn't need it's own get/set for ethtool tx csum, and it
> should use the standard ethtool_op_get_link.
> 
> NOT TESTED (no CELL hardware).

It seems to work. I've been distracted with other spidernet issues;
I will forward your patch upstream early next week.

--linas
