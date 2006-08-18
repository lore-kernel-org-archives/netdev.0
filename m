From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET] IPv4 FIB configuration conversions
Date: Thu, 17 Aug 2006 18:16:09 -0700 (PDT)
Message-ID: <20060817.181609.112622635.davem@davemloft.net>
References: <20060815145723.147333034@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:43731
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932270AbWHRBQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 21:16:00 -0400
To: tgraf@suug.ch
In-Reply-To: <20060815145723.147333034@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 15 Aug 2006 16:57:23 +0200

> Replaces the rather ugly struct kern_rta + rtmsg with a new
> struct fib_config while converting everything to the new netlink
> api. Simplifies the FIB module interface quite a bit and allows
> changing internals while keeping a stable netlink interface.
> 
> Gets rid of things like passing on netlink_skb_parms all around
> the fib code etc.
> 
> Also fixes some memory corruptions that could be triggered via
> netlink messages, not sure which would actually lead to an oops
> though.

All applied, thanks a lot Thomas.
