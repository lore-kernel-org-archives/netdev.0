From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH v2 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Thu, 23 Feb 2012 12:47:55 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293178F468@DBDE01.ent.ti.com>
References: <1329763023-29580-1-git-send-email-mugunthanvnm@ti.com>
	 <1329763023-29580-3-git-send-email-mugunthanvnm@ti.com>
 <1329779029.8318.21.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:48258 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752277Ab2BWMsE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 07:48:04 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe/David

> -----Original Message-----
> From: N, Mugunthan V
> Sent: Wednesday, February 22, 2012 10:13 PM
> To: 'Joe Perches'
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: RE: [PATCH v2 2/2] netdev: driver: ethernet: Add TI CPSW driver
> 
> Joe
> 
> > -----Original Message-----
> > From: Joe Perches [mailto:joe@perches.com]
> > Sent: Tuesday, February 21, 2012 4:34 AM
[...]
> > Add
> > #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > before all #includes and remove the embedded prefix
> > from all pr_<level> uses.
> 
> Agreed, will make use of pr_fmt and remove embedded prefix in pr_<level>
> uses
Adding 
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
in the driver gives a checkpatch error as follows

#77: FILE: drivers/net/ethernet/ti/cpsw.c:16:
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

total: 1 errors, 0 warnings, 1137 lines checked

Is it ok to ignore the checkpatch error as most of the drivers use it.

[...] 

With regards
Mugunthan V N
