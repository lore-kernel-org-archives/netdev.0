From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH v2 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Thu, 23 Feb 2012 16:38:32 +0000
Message-ID: <20120223163832.GB3236@shadowen.org>
References: <1329763023-29580-1-git-send-email-mugunthanvnm@ti.com>
 <1329763023-29580-3-git-send-email-mugunthanvnm@ti.com>
 <1329779029.8318.21.camel@joe2Laptop>
 <EB1619762EAF8B4E97A227FB77B7E0293178F468@DBDE01.ent.ti.com>
 <1330011962.5143.50.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "N, Mugunthan V" <mugunthanvnm@ti.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waldorf.bytemark.co.uk ([212.110.162.22]:32941 "EHLO
	waldorf.bytemark.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501Ab2BWRM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 12:12:56 -0500
Content-Disposition: inline
In-Reply-To: <1330011962.5143.50.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2012 at 07:46:02AM -0800, Joe Perches wrote:
> On Thu, 2012-02-23 at 12:47 +0000, N, Mugunthan V wrote:
> > Joe/David
> > > > -----Original Message-----
> > > > From: Joe Perches [mailto:joe@perches.com]
> > > > Sent: Tuesday, February 21, 2012 4:34 AM
> > [...]
> > > > Add
> > > > #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > > > before all #includes and remove the embedded prefix
> > > > from all pr_<level> uses.
> > > Agreed, will make use of pr_fmt and remove embedded prefix in pr_<level>
> > > uses
> > Adding 
> > #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > in the driver gives a checkpatch error as follows
> > #77: FILE: drivers/net/ethernet/ti/cpsw.c:16:
> > +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > total: 1 errors, 0 warnings, 1137 lines checked
> > Is it ok to ignore the checkpatch error as most of the drivers use it.
> 
> Yes.
> 
> Andy Whitcroft has a pending checkpatch fix
> for this.  I hope he pushes it out soon.

Bah good reminder.  Will get those re-tested and out as soon as I can
...

-apw
