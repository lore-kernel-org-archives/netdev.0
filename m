From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] (5/25) sk98: elimnate nested macro.
Date: Tue, 16 Nov 2004 08:23:50 +0000
Message-ID: <20041116082350.GB24321@infradead.org>
References: <20041115150910.0f3b8498@zqx3.pdx.osdl.net> <20041115152208.6684c483@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041115152208.6684c483@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 15, 2004 at 03:22:08PM -0800, Stephen Hemminger wrote:
> Replace nested macros to handle defining 64bit constants with
> simpler macro. Would prefer to just remove it but it gets used in multiple
> OS common code.

I don't think the driver is complex enough for all that os-common mess.
If you look at the BSD sk driver it's about a third of the size of the
Linux driver because it doesn't have all this mess.
