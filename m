From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: Use pr_<level> and netdev_<level>
Date: Fri, 26 Mar 2010 20:52:48 -0700 (PDT)
Message-ID: <20100326.205248.258788303.davem@davemloft.net>
References: <1269474180.1541.11.camel@Joe-Laptop.home>
	<8DD2590731AB5D4C9DBF71A877482A9061B3334E@orsmsx509.amr.corp.intel.com>
	<1269475474.1541.20.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57694
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751477Ab0C0Dw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 23:52:27 -0400
In-Reply-To: <1269475474.1541.20.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 24 Mar 2010 17:04:34 -0700

> hw and adapter are locally scoped in each function here,
> but are not local to the macro.  That can make conversions
> of macros to functions difficult.

This is pretty common practice in drivers though.

Especially for register accessors and whatnot, and I see no problem
doing it here.

All specifying these args explicitly will do is make the fingers move
one step closer to carpel tunnel. :-)

