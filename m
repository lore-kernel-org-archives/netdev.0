From: "David S. Miller" <davem@redhat.com>
Subject: Re: netdev_ops?
Date: Tue, 22 Jul 2003 23:27:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030722232719.216d7823.davem@redhat.com>
References: <3F1E17BC.30100@candelatech.com>
	<20030722220745.379a73c6.davem@redhat.com>
	<3F1E1D62.90009@candelatech.com>
	<20030722230215.284dd270.davem@redhat.com>
	<3F1E2A00.5080506@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F1E2A00.5080506@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jul 2003 23:24:00 -0700
Ben Greear <greearb@candelatech.com> wrote:

> My goal is a place to add new generic net-device ioctls without having
> to worry about testing the ioctls on various platforms

Your patch adds ethtool stuff, which works perfectly fine
on all platforms, even sparc64 when executing 32-bit binaries.

Just add it to your drivers if you want them supported in
2.4.x

> (You've said
> before you don't like when I try to add new ioctls because I break SPARC and
> who knows what else...)

You're not adding new ioctls here, you adding a default implementation
of an existing ioctl, and this kind of code is of no issue wrt
SPARC/PPC/MIPS/etc. ioctl translation for 32-bit applications running
on a 64-bit kernel.

> My patch looks like this, and it has zero impact on drivers.  It's primary
> benefit is to get around adding more ioctls:

You gain nothing from this patch, just put it into your drivers.

Your patch is even more useless than I thought it was going to
be. :-)
