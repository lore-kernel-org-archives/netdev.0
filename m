From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net-2.6.19] net/*: don't panic
Date: Tue, 29 Aug 2006 17:52:49 -0700 (PDT)
Message-ID: <20060829.175249.15691677.davem@davemloft.net>
References: <20060828093651.GA31341@infradead.org>
	<20060828.133637.107685776.davem@davemloft.net>
	<20060829034443.GB5192@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14809
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750831AbWH3Awr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 20:52:47 -0400
To: adobriyan@gmail.com
In-Reply-To: <20060829034443.GB5192@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 29 Aug 2006 07:50:43 +0400

> IPv6 can be modular and panicking on module loading is the last thing
> you want.
> 
> Two SLAB_PANIC cases converted to error propagating as well as one
> panic() call.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

This adds a call to addrconf_cleanup() from __init code, but that
function is marked __exit.  This will cause link errors in some
configurations.
