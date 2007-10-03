From: iank@bredband.net
Subject: Re: [PATCH] sky2: jumbo frame regression fix
Date: Wed, 3 Oct 2007 10:29:32 +0200
Message-ID: <20071003082932.GD32073@pomac.netswarm.net>
References: <1191372129.26233.12.camel@localhost> <20071002180209.47c350a3@freepuppy.rosehill> <1191375274.26233.17.camel@localhost> <20071002215914.13d1e8cf@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pomac@vapor.com, Jeff Garzik <jgarzik@pobox.com>,
	Linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy3.bredband.net ([195.54.101.73]:39795 "EHLO
	proxy3.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbXJCIaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 04:30:20 -0400
Content-Disposition: inline
In-Reply-To: <20071002215914.13d1e8cf@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 09:59:14PM -0700, Stephen Hemminger wrote:
> On Wed, 03 Oct 2007 03:34:34 +0200
> Ian Kumlien <pomac@vapor.com> wrote:
> 
> > On tis, 2007-10-02 at 18:02 -0700, Stephen Hemminger wrote:
> > > Remove unneeded check that caused problems with jumbo frame sizes.
> > > The check was recently added and is wrong.
> > > When using jumbo frames the sky2 driver does fragmentation, so
> > > rx_data_size is less than mtu.
> > 
> > Confirmed working.
> > 
> > Now running with 9k mtu with no errors, =)
> > 
> > It also seems that the FIFO bug was the one that affected me before,
> > damn odd race that one.
> 
> Does the workaround (forced reset work). Ian, you are the first person to
> report triggering it.  I haven't found a way to make it happen.
> What combination of flow control and speeds are you using?

I forgot to add, last time was -rc8-git2 or 3 and using Westwood flow
control.

> -- 
> Stephen Hemminger <shemminger@linux-foundation.org>
