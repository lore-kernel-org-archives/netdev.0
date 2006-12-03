From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rose_add_loopback_node: propagate -E
Date: Sun, 03 Dec 2006 00:59:25 -0800 (PST)
Message-ID: <20061203.005925.39159439.davem@davemloft.net>
References: <20061202213339.GB2714@martell.zuzino.mipt.ru>
	<20061203085210.GA12645@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:28093
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S935674AbWLCJAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 04:00:11 -0500
To: ralf@linux-mips.org
In-Reply-To: <20061203085210.GA12645@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Sun, 3 Dec 2006 08:52:10 +0000

> On Sun, Dec 03, 2006 at 12:33:39AM +0300, Alexey Dobriyan wrote:
> 
> > David Binderman's icc logs:
> > net/rose/rose_route.c(399): remark #593: variable "err" was set but never used
> 
> Which is more of a non-fix because all the callers ignore the return
> value ...

Well at least now we can make the callers check that value
and expect it to actually happen :)
