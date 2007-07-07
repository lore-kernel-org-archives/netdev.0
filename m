From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 5/9] netconsole: Introduce dev_status member
Date: Sat, 7 Jul 2007 13:38:47 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707071330300.24470@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110804.28520.25792.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704135642.GB11115@waste.org> <20070705081703.7bcc28bc@oldman>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:56826 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbXGGHrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jul 2007 03:47:00 -0400
In-Reply-To: <20070705081703.7bcc28bc@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On Thu, 5 Jul 2007, Stephen Hemminger wrote:
> On Wed, 4 Jul 2007 08:56:42 -0500
> Matt Mackall <mpm@selenic.com> wrote:
> [...]
> > > +	if (nt->dev_status) {
> > 
> > Why not simply call net_dev_is_up?
> 
> The flags field values are really BSD legacy-ish stuff and should not be
> used internally. IFF_UP etc, do not have the necessary atomic properties.
> 
> Use netif_running() instead.

Ok, thanks for letting me know about that. I'll make the change.

Satyam
