From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 1/2] phylib: Support phy module autoloading
Date: Fri, 02 Apr 2010 12:14:55 +0100
Message-ID: <1270206895.3101.2467.camel@macbook.infradead.org>
References: <1270096441.12516.18.camel@localhost>
	 <1270141428.3101.399.camel@macbook.infradead.org>
	 <20100401180511.GQ16821@decadent.org.uk>
	 <20100401.193810.172601735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org, 553024@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56201 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909Ab0DBLPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 07:15:00 -0400
In-Reply-To: <20100401.193810.172601735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-01 at 19:38 -0700, David Miller wrote:
> Whatever you submit
> next I'd like to toss into net-next-2.6 so it can cook for a while
> and maybe we'll backport it so that this bug can be fixed for good
> upstream and then perhaps even in -stable. 

When backporting, note that you'll need s/PHY_ID_BCMAC131/0x0143bc70/ in
the patch to broadcom.c, because 2.6.32 didn't have a definition for
that.

There's also trivial change in phy_device_create() which will make the
patch fail to apply, but git-cherry-pick copes.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

