From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Thu, 30 Jan 2014 15:17:47 +0100
Message-ID: <20140130141747.GC25336@order.stressinduktion.org>
References: <20140118191107.GA21979@sesse.net> <20140119181806.GC16462@order.stressinduktion.org> <20140120184025.GA19972@sesse.net> <20140130104709.GA21178@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46863 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750AbaA3ORs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 09:17:48 -0500
Content-Disposition: inline
In-Reply-To: <20140130104709.GA21178@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 11:47:09AM +0100, Steinar H. Gunderson wrote:
> On Mon, Jan 20, 2014 at 07:40:25PM +0100, Steinar H. Gunderson wrote:
> >> I currently only remember one commit 0a7e22609067ff ("ipv4: fix
> >> ineffective source address selection") which did affect multicast source
> >> address selection in recent times.
> > I tried 3.10.27, just to check something older. I also tried 3.10.27 with
> > 0a7e22609067ff reverted, and it's still wrong.
> > 
> > I am thinking this might have something to do with the machine switching to
> > systemd, presumably changing the order of DHCP and static addresses being
> > assigned...
> 
> Anything more I can do here?

Can you give a bit more background what multicast application you are running
on the box and also post a cat /proc/net/igmp?

(For the application info an strace how the join to the multicast address would be
interesting.)

I guess a workaround would be to bind the join to a specific interface.

Greetings,

  Hannes
