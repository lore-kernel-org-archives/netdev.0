From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.26.y] sch_prio: Fix nla_parse_nested_compat()
 regression
Date: Tue, 02 Sep 2008 17:31:41 -0700 (PDT)
Message-ID: <20080902.173141.247481496.davem@davemloft.net>
References: <20080828101840.GZ20815@postel.suug.ch>
	<20080828.031943.114025230.davem@davemloft.net>
	<20080828130331.GA20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, shemminger@vyatta.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	alexander.h.duyck@intel.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754305AbYICAbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 20:31:47 -0400
In-Reply-To: <20080828130331.GA20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 28 Aug 2008 15:03:31 +0200

> nla_parse_nested_compat() was used to parse two different message
> formats in the netem and prio qdisc, when it was "fixed" to work
> with netem, it broke the multi queue support in the prio qdisc.
> Since the prio qdisc code in question is already removed in the
> development tree, this patch only fixes the regression in the
> stable tree.
> 
> Based on original patch from Alexander H Duyck <alexander.h.duyck@intel.com>
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I'll queue this up for -stable, thanks Thomas.
