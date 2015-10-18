From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/7] tty: Remove ASYNC_CLOSING checks in open()/hangup()
 methods
Date: Sat, 17 Oct 2015 21:13:21 -0700
Message-ID: <20151018041321.GA8229@kroah.com>
References: <1444507257-7513-1-git-send-email-peter@hurleysoftware.com>
 <1444507257-7513-3-git-send-email-peter@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jslaby@suse.cz>, Alan Cox <alan@linux.intel.com>,
	David Laight <David.Laight@aculab.com>,
	Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444507257-7513-3-git-send-email-peter@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 10, 2015 at 04:00:52PM -0400, Peter Hurley wrote:
> 
> Note: The ASYNC_CLOSING flag state is still maintained since several
> bitrotting drivers use it for (dubious) other purposes.

I think we should drop it, it's pointless and no one ever actually does
anything with it.

thanks,

greg k-h
