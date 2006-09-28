From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Wed, 27 Sep 2006 19:06:01 -0700 (PDT)
Message-ID: <20060927.190601.26530992.davem@davemloft.net>
References: <451AC889.5000407@redhat.com>
	<20060927.161638.62343616.davem@davemloft.net>
	<20060927160044.68ffca2e@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: woodard@redhat.com, netdev@vger.kernel.org, mgrondona@llnl.gov,
	behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65003
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965193AbWI1CGD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 22:06:03 -0400
To: shemminger@osdl.org
In-Reply-To: <20060927160044.68ffca2e@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 27 Sep 2006 16:00:44 -0700

> On Wed, 27 Sep 2006 16:16:38 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Ben Woodard <woodard@redhat.com>
> > Date: Wed, 27 Sep 2006 11:52:57 -0700
> > 
> > > Because these are general utility clusters we run many different 
> > > programs and so trying to fix this problem in the application is not 
> > > possible since there are literally hundreds if not thousands of them.
> > 
> > Then why add a socket option setting as your patch does? :-)
> > 
> > I also object to the socket option setting being allowed for
> > any user because this can have awful effects if allowed by
> > arbitrary users on arbitrary networks.
> 
> Setting a cwnd limit would do the same thing.

Not really :-)

It would not influence the TCP retransmit timeouts and
backoff, although it would influence the congestion window
handling during recovery after such timeout based losses.
