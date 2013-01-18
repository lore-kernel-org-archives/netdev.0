From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to
 drivers/net
Date: Fri, 18 Jan 2013 14:57:06 -0800
Message-ID: <20130118225706.GA22140@kroah.com>
References: <1358541648-29922-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, sfr@canb.auug.org.au,
	devel@driverdev.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358541648-29922-1-git-send-email-mark.einon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 18, 2013 at 08:40:47PM +0000, Mark Einon wrote:
> This patch moves the et131x gigabit ethernet driver from drivers/staging
> to drivers/net/ethernet/agere.
> 
> All the existing issues noted for this driver have been resolved, apart
> from one performance issue where some fragmented packets suffer from
> frame receive errors. As I've only tested the code on one piece of
> hardware to date, it would be useful to get feedback on this issue from
> any other users of the device (my device has been stepped on several times
> now, and is known to need a few wiggles before starting up correctly).
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>

No objection from me for this.  It's up to the network driver
maintainers if this is ok or not.

greg k-h
