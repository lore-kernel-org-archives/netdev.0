From: Joe Perches <joe@perches.com>
Subject: RE: [PATCH v2 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Thu, 23 Feb 2012 07:46:02 -0800
Message-ID: <1330011962.5143.50.camel@joe2Laptop>
References: <1329763023-29580-1-git-send-email-mugunthanvnm@ti.com>
	 <1329763023-29580-3-git-send-email-mugunthanvnm@ti.com>
	 <1329779029.8318.21.camel@joe2Laptop>
	  <EB1619762EAF8B4E97A227FB77B7E0293178F468@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>,
	Andy Whitcroft <apw@shadowen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54570 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751851Ab2BWPqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Feb 2012 10:46:05 -0500
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293178F468@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-23 at 12:47 +0000, N, Mugunthan V wrote:
> Joe/David
> > > -----Original Message-----
> > > From: Joe Perches [mailto:joe@perches.com]
> > > Sent: Tuesday, February 21, 2012 4:34 AM
> [...]
> > > Add
> > > #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > > before all #includes and remove the embedded prefix
> > > from all pr_<level> uses.
> > Agreed, will make use of pr_fmt and remove embedded prefix in pr_<level>
> > uses
> Adding 
> #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> in the driver gives a checkpatch error as follows
> #77: FILE: drivers/net/ethernet/ti/cpsw.c:16:
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> total: 1 errors, 0 warnings, 1137 lines checked
> Is it ok to ignore the checkpatch error as most of the drivers use it.

Yes.

Andy Whitcroft has a pending checkpatch fix
for this.  I hope he pushes it out soon.
