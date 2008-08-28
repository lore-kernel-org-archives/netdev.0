From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] IPROUTE: generate compat messages that match
 nla_parse_nested_compat
Date: Thu, 28 Aug 2008 02:55:28 -0700 (PDT)
Message-ID: <20080828.025528.56442281.davem@davemloft.net>
References: <20080828011340.7987.74684.stgit@jtkirshe-mobile.jf.intel.com>
	<20080828011347.7987.24759.stgit@jtkirshe-mobile.jf.intel.com>
	<20080828095131.GX20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47153
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751285AbYH1Jzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 05:55:33 -0400
In-Reply-To: <20080828095131.GX20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 28 Aug 2008 11:51:31 +0200

> * Jeff Kirsher <jeffrey.t.kirsher@intel.com> 2008-08-27 18:13
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> > 
> > This patch updates libnetlink.c to generate nested compat netlink
> > attributes in the same format that is parsed by the kernels 2.6.26
> > and newer.
> > 
> > This patch will fix the prio multiqueue option for 2.6.26 kernels,
> > but will break compatibility with all kernels prior to 2.6.26.
> 
> I'm not sure what you mean by fix, I can't find any nested attributes
> being parsed in the proposed sch_multiq.c.

He's doing the bogus iproute2 alternative to curing the regression
in PRIO and RR that was added to 2.6.26 and 2.6.25.7

That's what this is for.

But see my other email, we'll likely fix this in the kernel.
