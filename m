From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/7] Drop support for Renesys H8/300 architecture
Date: Fri, 30 Aug 2013 09:55:50 -0700
Message-ID: <20130830165550.GA8151@kroah.com>
References: <1377880842-6835-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org,
	netdev@vger.kernel.org, linux-watchdog@vger.kernel.org,
	Wim Van Sebroeck <wim@iguana.be>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Paris <eparis@redhat.com>,
	Jiang Liu <jiang.liu@huawei.com>,
	David Howells <dhowells@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1377880842-6835-1-git-send-email-linux@roeck-us.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 30, 2013 at 09:40:35AM -0700, Guenter Roeck wrote:
> H8/300 has been dead for several years, the kernel for it has
> not compiled for ages, and recent versions of gcc for it are broken.
> It is time to drop support for it.
> 
> Yes, I understand it is not that simple to drop an architecture,
> and it may need some discussion, but someone has to put a stake
> into the ground. Keeping a virtually dead architecture on life support
> takes resources which are better spent elsewhere.

If this doesn't build, and no one is using it anymore, I agree, it
should be removed.  If someone wants to revive it, 'git revert' works
just fine.

You can put my:

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

on these patches, unless someone steps up to be the active maintainer of
the arch and gets it building/working again.

thanks,

greg k-h
