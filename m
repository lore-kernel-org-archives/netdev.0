From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPVS] use msleep_interruptable() instead of ssleep()
 aka msleep()
Date: Sun, 10 Dec 2006 22:35:41 -0800 (PST)
Message-ID: <20061210.223541.108741763.davem@davemloft.net>
References: <20061128062716.GA32377@verge.net.au>
	<Pine.LNX.4.58.0611281031190.2787@u.domain.uli>
	<20061129005834.GA25535@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org, deanm@ispone.com.au,
	wensong@linux-vs.org, jmack@wm7d.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762575AbWLKGfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 01:35:43 -0500
To: horms@verge.net.au
In-Reply-To: <20061129005834.GA25535@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Horms <horms@verge.net.au>
Date: Wed, 29 Nov 2006 09:58:35 +0900

> On Tue, Nov 28, 2006 at 10:35:01AM +0200, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Tue, 28 Nov 2006, Horms wrote:
> > 
> > > Dean Manners notices that when an IPVS synchonisation daemons are
> > > started the system load slowly climbs up to 1. This seems to be related
> > > to the call to ssleep(1) (aka msleep(1000) in the main loop. Replacing
> > > this with a call to msleep_interruptable() seems to make the problem go
> > > away. Though I'm not sure that it is correct.
> > 
> > 	The same is needed for sync_backup_loop
> 
> Good point. It also seems as well to change it in fork_sync_thread()
> and start_sync_thread(), though these are unlikely to be causing a problem.

Applied, thanks Simon.

