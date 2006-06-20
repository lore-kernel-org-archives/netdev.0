From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 20 Jun 2006 10:59:04 -0400
Message-ID: <1150815544.5270.82.camel@jzny2>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>
	 <1150289724.26181.74.camel@localhost.localdomain>
	 <1150377383.5116.38.camel@jzny2>  <4497499F.8040507@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hawk@diku.dk, russell-tcatm@stuart.id.au, lartc@mailman.ds9a.nl,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:44972 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751286AbWFTO7G
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 10:59:06 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fshh7-0005et-7Q
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 10:59:09 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4497499F.8040507@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-20-06 at 03:04 +0200, Patrick McHardy wrote:
> jamal wrote:
> > You are still speaking ATM (and the above may still be valid), but: 
> > Could you for example look at the netdevice->type and from that figure
> > out the link layer overhead and compensate for it.
> > Obviously a lot more useful if such activity is doable in user space
> > without any knowledge of the kernel? and therefore zero change to the
> > kernel and everything then becomes forward and backward compatible.
> 
> It would be nice to have support for HFSC as well, which unfortunately
> needs to be done in the kernel since it doesn't use rate tables.
> What about qdiscs like SFQ (which uses the packet size in quantum
> calculations)? I guess it would make sense to use the wire-length
> there as well.

Didnt even think of that ;-> 
Is it getting too complicated? 

BTW, I forgot to mention one thing on the bandwidth issue is we could do
is send netlink events on link speed changes too; some listener
somewhere would then do the adjustment.

cheers,
jamal

