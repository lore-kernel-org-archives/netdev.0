From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 1/3] bonding: allow previous slave to be used when
	re-balancing traffic on tlb/alb interfaces
Date: Tue, 6 Oct 2009 12:27:31 -0400
Message-ID: <20091006162731.GC1639@gospo.rdu.redhat.com>
References: <1254269731-7341-1-git-send-email-fubar@us.ibm.com> <1254269731-7341-2-git-send-email-fubar@us.ibm.com> <8075.1254532437@death.nxdomain.ibm.com> <20091005.034333.04801045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750870AbZJFQ2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2009 12:28:21 -0400
Content-Disposition: inline
In-Reply-To: <20091005.034333.04801045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 05, 2009 at 03:43:33AM -0700, David Miller wrote:
> From: Jay Vosburgh <fubar@us.ibm.com>
> Date: Fri, 02 Oct 2009 18:13:57 -0700
> 
> > 	Andy, I've been doing some further testing with this patch, and
> > I'm seeing some panics that I believe are related to this patch.  It
> > appears that the last_slave isn't cleared (or isn't cleared soon enough)
> > when a slave is released, and concurrent transmit activity is getting
> > into alb_get_best_slave() and finding a last_slave pointer that is stale
> > (points to no slave currently on the slave list).
> 
> I'm holding off on these 3 bonding patches until this is resolved.
> --

Sounds good, Dave.

I was hoping to get this resolved yesterday, but got distracted.  I will
have some time today.

