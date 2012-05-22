From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3] drop_monitor: convert to modular building
Date: Tue, 22 May 2012 09:57:39 -0400
Message-ID: <20120522135739.GA5481@hmsreliant.think-freely.org>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
 <1337285040-20848-1-git-send-email-nhorman@tuxdriver.com>
 <20120517.160937.586334759945738635.davem@davemloft.net>
 <20120517202152.GB19321@hmsreliant.think-freely.org>
 <1337691919.3361.189.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36744 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964Ab2EVN5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 09:57:52 -0400
Content-Disposition: inline
In-Reply-To: <1337691919.3361.189.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 22, 2012 at 03:05:19PM +0200, Eric Dumazet wrote:
> On Thu, 2012-05-17 at 16:21 -0400, Neil Horman wrote:
> > On Thu, May 17, 2012 at 04:09:37PM -0400, David Miller wrote:
> 
> > > 
> > > Applied, althrough it didn't apply cleanly to net-next.
> > > 
> > 
> > Apologies Dave, should have told you that I was carrying Joe P.'s cleanup patch
> > in my net-next tree as well:
> > http://marc.info/?l=linux-netdev&m=133727344816140&w=2
> > 
> > Since you noted that you had applied it, I applied it myself here.
> > Neil
> > 
> 
> Any plan to autoload drop_monitor module from dropwatch,
> or issuing some advice ?
> 
> # dropwatch -l kas
> Unable to find NET_DM family, dropwatch can't work
> Cleanuing up on socket creation error
> 
> Thanks
> 
I'm looking into that currently, although I was starting to wonder if its
possible to do with a generic netlink socket.  I can't seem to find any
examples, and I can't use the net-pf-* module alias mechanism that formal
protocols implement, since I don't have a defined address family.  I suppose I
could augment that format to support a net-pf-16-<name> alias, where name is the
name of the genl family that gets registered by the module you're looking for.

Does that seem like a reasonable idea?
Neil

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
