From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: No need to wake queue in xmit handler
Date: Sat, 17 Oct 2009 23:57:54 -0700 (PDT)
Message-ID: <20091017.235754.30013108.davem@davemloft.net>
References: <20091015055419.30109.16062.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50040
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752076AbZJRG5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 02:57:32 -0400
In-Reply-To: <20091015055419.30109.16062.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Thu, 15 Oct 2009 11:24:19 +0530

> The xmit handler doesn't need to wake the queue after stopping
> it temporarily (some other drivers are doing the same).
> 
> Patch on net-next-2.6, multiple netperf sessions tested.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Applied.
