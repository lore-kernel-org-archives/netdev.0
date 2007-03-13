From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch 4/4] [TULIP] Rev tulip version
Date: Tue, 13 Mar 2007 13:07:34 -0400
Message-ID: <20070313170733.GB28281@gospo.rdu.redhat.com>
References: <20070312093128.577087000@linux.intel.com> <20070312095912.743760000@linux.intel.com> <84144f020703120344n3f5ed52axf0bc1c109b549535@mail.gmail.com> <45F55EA5.9080005@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Valerie Henson <val_henson@linux.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030797AbXCMRHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 13:07:46 -0400
Content-Disposition: inline
In-Reply-To: <45F55EA5.9080005@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 12, 2007 at 10:07:33AM -0400, Jeff Garzik wrote:
> Pekka Enberg wrote:
> >Hi,
> >
> >On 3/12/07, Valerie Henson <val_henson@linux.intel.com> wrote:
> >>--- tulip-2.6-mm-linux.orig/drivers/net/tulip/tulip_core.c
> >>+++ tulip-2.6-mm-linux/drivers/net/tulip/tulip_core.c
> >>@@ -17,11 +17,11 @@
> >>
> >> #define DRV_NAME       "tulip"
> >> #ifdef CONFIG_TULIP_NAPI
> >>-#define DRV_VERSION    "1.1.14-NAPI" /* Keep at least for test */
> >>+#define DRV_VERSION    "1.1.15-NAPI" /* Keep at least for test */
> >> #else
> >>-#define DRV_VERSION    "1.1.14"
> >>+#define DRV_VERSION    "1.1.15"
> >> #endif
> >>-#define DRV_RELDATE    "May 11, 2002"
> >>+#define DRV_RELDATE    "Feb 27, 2007"
> >
> >Why not just drop this? What purpose does a per-module revision have
> >for in-kernel drivers anyway?
> 
> It's the maintainer's call.  Sometimes it eases parsing bug reports, and 
> tracking changes as your drivers get backported to various enterprise 
> operating systems(tm).  Sometimes it just gets in the way.
> 

It's good to keep this type of information in drivers.  I've been
thinking lately that it would be nice to even expand it a little bit
(maybe include the commit sum) so its easier to help those who aren't
running the latest upstream kernels on their boxes....

