From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 6/9] fs_enet: Be an of_platform device when CONFIG_PPC_CPM_NEW_BINDING is set.
Date: Thu, 20 Sep 2007 19:44:06 -0500
Message-ID: <20070921004406.GA19279@ld0162-tx32.am.freescale.net>
References: <20070920220043.GA28769@loki.buserror.net> <20070920220121.GF28784@loki.buserror.net> <20070921100841.6904f2bc.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:48134 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbXIUAok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 20:44:40 -0400
Content-Disposition: inline
In-Reply-To: <20070921100841.6904f2bc.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 21, 2007 at 10:08:41AM +1000, Stephen Rothwell wrote:
> On Thu, 20 Sep 2007 17:01:21 -0500 Scott Wood <scottwood@freescale.com> wrote:
> >
> > +++ b/drivers/net/fs_enet/fs_enet-main.c
> > @@ -44,12 +44,18 @@
> >  #include <asm/irq.h>
> >  #include <asm/uaccess.h>
> >  
> > +#ifdef CONFIG_PPC_CPM_NEW_BINDING
> > +#include <asm/of_platform.h>
> 
> Hmm, didn't I already ask you to change this to linux/of_platform.h?

Grrr, I thought I'd gotten them all.
 
-Scott
