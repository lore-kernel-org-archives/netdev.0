From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] IPROUTE: generate compat messages that match nla_parse_nested_compat
Date: Thu, 28 Aug 2008 11:59:48 +0200
Message-ID: <20080828095948.GY20815@postel.suug.ch>
References: <20080828011340.7987.74684.stgit@jtkirshe-mobile.jf.intel.com> <20080828011347.7987.24759.stgit@jtkirshe-mobile.jf.intel.com> <20080828095131.GX20815@postel.suug.ch> <20080828.025528.56442281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:57144 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751123AbYH1J71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 05:59:27 -0400
Content-Disposition: inline
In-Reply-To: <20080828.025528.56442281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller <davem@davemloft.net> 2008-08-28 02:55
> He's doing the bogus iproute2 alternative to curing the regression
> in PRIO and RR that was added to 2.6.26 and 2.6.25.7
> 
> That's what this is for.
> 
> But see my other email, we'll likely fix this in the kernel.

The prio scheduler also no longer parses nested attributes, you have
removed that piece of code when you removed RR. There is nothing to
fix really.  multiq is currently the only "real" user of
addattr_nest_compat().

