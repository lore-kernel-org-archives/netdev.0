From: David Miller <davem@davemloft.net>
Subject: Re: [patch 04/13] IRDA: Replace hard-coded dev_self[] array sizes
 with ARRAY_SIZE()
Date: Tue, 15 Aug 2006 00:10:05 -0700 (PDT)
Message-ID: <20060815.001005.93384986.davem@davemloft.net>
References: <200608150603.k7F63dbr012933@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bjorn.helgaas@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21428
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965252AbWHOHKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:10:03 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63dbr012933@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 14 Aug 2006 23:03:39 -0700

> From: Bjorn Helgaas <bjorn.helgaas@hp.com>
> 
> Several IR drivers used "for (i = 0; i < 4; i++)" to walk their dev_self[]
> table.  Better to use ARRAY_SIZE().  And fix ali-ircc so it won't run off
> the end if we find too many adapters.
> 
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.19
