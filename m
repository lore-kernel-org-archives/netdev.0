From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH] net: tun/tap: fixed hw address handling
Date: Mon, 26 Mar 2007 23:05:58 +0200
Message-ID: <20070326210558.GC21991@Ahmed>
References: <460632E9.5030508@bristyle.com> <20070326205511.GB21991@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Max Krasnyansky <maxk@qualcomm.com>, vtun@office.satix.net,
	akpm@osdl.org, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Brian Braunstein <brian@bristyle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:65333 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbXCZVGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 17:06:20 -0400
Received: by nf-out-0910.google.com with SMTP id o25so3029902nfa
        for <netdev@vger.kernel.org>; Mon, 26 Mar 2007 14:06:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070326205511.GB21991@Ahmed>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 26, 2007 at 10:55:11PM +0200, ahmed wrote:
> On Sun, Mar 25, 2007 at 01:29:29AM -0700, Brian Braunstein wrote:
> > --- linux-2.6.20.4-ORIG/drivers/net/tun.c	2007-03-23 
> > 12:52:51.000000000 -0700
> > +++ linux-2.6.20.4/drivers/net/tun.c	2007-03-25 00:44:20.000000000 -0700
> > @@ -18,6 +18,10 @@
> > /*
> >  *  Changes:
> >  *
> > + *  Brian Braunstein <linuxkernel@bristyle.com> 2007/03/23
> > + *    Fixed hw address handling.  Now net_device.dev_addr is kept 
> > consistent
> 
> Your mailer still wrap the long lines mistakenly as it did in the first
> version of the patch.
> 

It seems a bug in my mutt mail reader (not a feature, it displays other 
mails long lines without wrapping), sorry.

-- 
Ahmed S. Darwish
http://darwish.07.googlepages.com

