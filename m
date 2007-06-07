From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet: checksum and ethtool
Date: Thu, 7 Jun 2007 11:45:11 -0500
Message-ID: <20070607164511.GO28472@austin.ibm.com>
References: <20070529172436.3cd60dcf@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:34780 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbXFGQpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 12:45:12 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57GjCBs006555
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 12:45:12 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57GjCPP263640
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 10:45:12 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57GjBPH027992
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 10:45:12 -0600
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

Can you provide a signed-off-by line, please?  I was hoping to submit
upstream today.

--linas

