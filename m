From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 3/5] net: add NL802154 interface for configuration of
	802.15.4 devices
Date: Fri, 5 Jun 2009 11:15:29 +0400
Message-ID: <20090605071529.GA7064@doriath.ww600.siemens.net>
References: <1244168990-28355-1-git-send-email-dbaryshkov@gmail.com> <1244168990-28355-2-git-send-email-dbaryshkov@gmail.com> <1244168990-28355-3-git-send-email-dbaryshkov@gmail.com> <1244168990-28355-4-git-send-email-dbaryshkov@gmail.com> <1244184737.22576.94.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, slapin@ossfans.org,
	davem@davemloft.net, Stephen Rothwell <sfr@canb.auug.org.au>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:27296 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbZFEHPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 03:15:44 -0400
Content-Disposition: inline
In-Reply-To: <1244184737.22576.94.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 05, 2009 at 08:52:17AM +0200, Johannes Berg wrote:
> On Fri, 2009-06-05 at 06:29 +0400, Dmitry Eremin-Solenikov wrote:
> 
> > +/* This source file is shared between kernel and userspace sources, thus
> > + * a bit of __KERNEL__ checks
> > + */
> > +#ifdef __KERNEL__
> 
> It's a C file. It can't be shared expect by copying, hence IMO these
> things are pointless.

It is shared by copying. And I'd strongly prefer to have it shared
directly by 'cp', not by 'cp' and 'patch'. E.g. currently I can ensure
that policy definitions and commands are current just by comparing
files. I'd like to still have that ability. Thus, I'd ask to permit this
stuff in.

-- 
With best wishes
Dmitry

