From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 21/21] drivers/net/tlan.h: Convert printk(KERN_DEBUG to pr_dbg(
Date: Mon, 5 Oct 2009 23:15:01 +0200
Message-ID: <200910052315.01357.rjw@sisk.pl>
References: <cover.1254701151.git.joe@perches.com> <20091005.001240.111554671.davem@davemloft.net> <1254726974.1799.315.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	chessman@tux.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754753AbZJEVOQ@vger.kernel.org>
In-Reply-To: <1254726974.1799.315.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 October 2009, Joe Perches wrote:
> On Mon, 2009-10-05 at 00:12 -0700, David Miller wrote:
> > From: Joe Perches <joe@perches.com>
> > Date: Sun,  4 Oct 2009 17:53:48 -0700
> > > Removed "TLAN: " prefix from debug printks, it's added by pr_fmt
> > > Signed-off-by: Joe Perches <joe@perches.com>
> > Applied to net-next-2.6
> 
> Patches 20 and 21 depend on patch 1, which introduces pr_dbg
> to kernel.h.  Compile failure otherwise.

Why don't you push the first patch first, then, and wait with the others until
it gets merged?  This way individual subsystem maintainers will be able to
merge them cleanly.

Rafael
