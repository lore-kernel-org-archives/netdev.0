From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] sdla non-module build fix.
Date: Mon, 8 Sep 2003 10:32:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081030310.15082-100000@home.osdl.org>
References: <20030908095708.107b98c4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030908095708.107b98c4.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mon, 8 Sep 2003, Stephen Hemminger wrote:
>
> Last round of changes broke sdla build if not a module.

This patch can't be right. It may fix the compile, but it looks like 
init/exit_sdla is never registered at all if it's built-in.

I suspect the whole #ifdef should go away. A driver that does things 
differently depending on whether it is a module or not is generally a 
_broken_ driver.

		Linus
