From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 3/3] bonding: Improve IGMP join processing
Date: Thu, 1 Mar 2007 14:43:06 -0500
Message-ID: <20070301194305.GB3199@gospo.rdu.redhat.com>
References: <200703010103.l2113b22030905@death.nxdomain.ibm.com> <20070301164918.GA3199@gospo.rdu.redhat.com> <200703011705.l21H5Q22005750@death.nxdomain.ibm.com> <45E7289F.60406@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Jeff Garzik <jgarzik@pobox.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965543AbXCATn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 14:43:26 -0500
Content-Disposition: inline
In-Reply-To: <45E7289F.60406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2007 at 02:25:19PM -0500, Brian Haley wrote:
> Jay Vosburgh wrote:
> >>My only concern is that this code assumes all mcast addresses stored in
> >>dev->mc-list list are for ipv4 igmp mcast addresses and nothing was done
> >>for ipv6.
> >>
> >>But this is much better than what we have now, so... 
> >
> >	Agreed, but there's no IPv6 support anywhere in bonding at
> >present (for unicast or multicast), so this isn't really a loss.
> 
> So forgive my naive question, but what would it take to make IPv6 work? 
>  I know DAD fails on a test setup I have, but I haven't dug-into why 
> this is (I can guess), and I'd like to see it working.  I'm willing to 
> help, even if just to get it limping along.
> 

Brian,

If we are easily able to differentiate between the multicast addresses
in the mc_list as to which are for ipv4 and which are for ipv6 then it
would be easy to call-out to something in the ipv6 mcast code when
needed instead of always calling out to ipv4 code.

-andy
