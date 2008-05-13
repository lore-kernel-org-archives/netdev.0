From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] [2.6.26] [CAN] Fix can_send() handling on
	dev_queue_xmit() failures
Date: Tue, 13 May 2008 10:46:33 -0700
Message-ID: <20080513174633.GA32288@kroah.com>
References: <4820B665.6070609@hartkopp.net> <20080508.025044.124227730.davem@davemloft.net> <482331B7.909@hartkopp.net> <20080508172938.GA7461@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <oliver@hartkopp.net>, stable@kernel.org,
	urs@isnogud.escape.de, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:57843 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756601AbYEMR44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 13:56:56 -0400
Content-Disposition: inline
In-Reply-To: <20080508172938.GA7461@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 08, 2008 at 07:29:38PM +0200, Sam Ravnborg wrote:
> On Thu, May 08, 2008 at 07:00:39PM +0200, Oliver Hartkopp wrote:
> > David Miller wrote:
> > >
> > >>this patch should go into 2.6.26 and also applies fine on 2.6.25.1.
> > >>
> > >>IMO this issue is not that 'critical' that it *requires* to become
> > >>part of 2.6.25.2. Please forward the patch to Greg at your own opinion.
> > >>    
> > >
> > >I think I'll push it to -stable, thanks.
> > >
> > >  
> > 
> > Thanks!
> > 
> > Maybe we should also consider to push the patch from Sam regarding the 
> > wrong copy_from_user() results interpretation to the stable tree:
> > 
> > can: Fix copy_from_user() results interpretation
> > 
> > author 	Sam Ravnborg <sam@ravnborg.org>
> > 
> > 	Sun, 27 Apr 2008 05:57:25 +0000 (22:57 -0700)
> > committer 	David S. Miller <davem@davemloft.net>
> > 
> > 	Sun, 27 Apr 2008 21:26:51 +0000 (14:26 -0700)
> > commit 	3f91bd420a955803421f2db17b2e04aacfbb2bb8
> 
> I recall tat I considered stable material when I did
> this patch. But as I merely just did a codingstyle update
> of the old patch I dropped it.
> 
> But looks like possible -stable materail so I've added
> stable@kernel.org to the to list so they can judge.

I trust David to send the -stable team any networking patches he things
needs to go there.  So it's really up to him.

thanks,

greg k-h
