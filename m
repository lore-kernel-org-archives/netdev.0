From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (4/25) sk98: change #define to typedef
Date: Thu, 18 Nov 2004 16:23:52 -0800
Message-ID: <20041118162352.7dda3e4c@zqx3.pdx.osdl.net>
References: <419A231F.4020104@syskonnect.de>
	<20041117150133.GA8874@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlindner@syskonnect.de>, Jeff Garzik <jgarzik@pobox.com>,
        Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com,
        Ralph Roesler
 <rroesler@syskonnect.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20041117150133.GA8874@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Nov 2004 15:01:34 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> > Note that the kernel BSD sk driver was _not_ written by SysKonnect and 
> > only supports Genesis and Yukon1; linux supports Genesis (single and 
> > dual), Yukon1, Yukon Plus, Yukon EC, Yukon FE and Yukon2 (single and 
> > dual).
> 
> They have Yukon2 support for while - unlike Linux.
> 
> > The BSD sk driver supports substantially less functionality than 
> > the Linux driver. For example, there is no link failover capability in 
> > the sk driver;

Is it even possible to do link failover with existing Open Source tools?

Also the whole Remote Link Mangement (RLMT) stuff has no security so
if it is used over a hostile network look out.

I intrigued by the idea of  of porting FreeBSD driver to Linux. But this card
is already taking more time than I want to spend.
