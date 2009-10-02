From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/8] SECURITY ISSUE with connector
Date: Fri, 2 Oct 2009 11:00:22 -0700
Message-ID: <20091002180022.GA22229@kroah.com>
References: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
 <20091002.105659.102583702.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: philipp.reisner@linbit.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	dm-devel@redhat.com, zbr@ioremap.net,
	linux-fbdev-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:36959 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752785AbZJBSCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 14:02:49 -0400
Content-Disposition: inline
In-Reply-To: <20091002.105659.102583702.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 02, 2009 at 10:56:59AM -0700, David Miller wrote:
> From: Philipp Reisner <philipp.reisner@linbit.com>
> Date: Fri,  2 Oct 2009 14:40:03 +0200
> 
> > Affected: All code that uses connector, in kernel and out of mainline
> > 
> > The connector, as it is today, does not allow the in kernel receiving
> > parts to do any checks on privileges of a message's sender.
> > 
> > I know, there are not many out there that like connector, but as
> > long as it is in the kernel, we have to fix the security issues it has!
> > 
> > Please either drop connector, or someone who feels a bit responsible
> > and has our beloved dictator's blessing, PLEASE PLEASE PLEASE take 
> > this into your tree, and send the pull request to Linus.
> > 
> > Patches 1 to 4 are already Acked-by Evgeny, the connector's maintainer.
> > Patches 5 to 7 are the obvious fixes to the connector user's code.
> > 
> > For convenience these patches are also available as git tree:
> > git://git.drbd.org/linux-2.6-drbd.git connector-fix
> 
> All applied to net-2.6, I'll push this out to Linus later
> today.

Should it also go to -stable?  If so, I can pick it up once it hits
Linus's tree.

thanks,

greg k-h
