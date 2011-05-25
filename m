From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] bonding: documentation and code cleanup for resend_igmp
Date: Wed, 25 May 2011 11:10:33 -0700
Message-ID: <1306347033.8149.1589.camel@tardy>
References: <1306334642-20733-1-git-send-email-fbl@redhat.com>
	 <1306343973.8149.1556.camel@tardy>  <4DDD3D6E.1040706@redhat.com>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:39737 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993Ab1EYSKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 14:10:36 -0400
In-Reply-To: <4DDD3D6E.1040706@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > 
> > Grammar nit - "prevents the ICMP membership report from being issued in
> > response to the failover event."  Or "prevents issuing of the IGMP
> > membership report in response to a failover event."
> 
> I like the first suggestion. I'll update the patch fixing the ICMP
> typo.

Petards, petards, everywhere - and why are they all pointing at me :)

> 
> >> +
> >> +	This option is useful for bonding modes balance-rr or 0,
> >> +	active-backup or 1, balance-tlb or 5, balance-alb or 6, which a
> >> +	failover can move the IGMP traffic from one slave to another.
> >> +	Therefore, the switch must be notified with an extra IGMP report
> >> +	to start forwarding the IGMP traffic over the new selected slave.
> > 
> > More nits.  How about (with some added guesses on my part about
> > direction)
> > 
> > This option is useful for bonding modes balance-rr (0), active-backup
> > (1), balance-tlb (5) and balance-alb (6), in which a failover can switch
> > the outgoing IGMP traffic from one slave to another.  Therefore a fresh
> > IGMP report must be issued to cause the switch to forward the incoming
> > IGMP traffic over the newly selected slave.
> 
> It's also better. thanks. However, the failover can switch both
> incoming and outgoing IGMP traffic so I'd leave it generic as before.
> For instance:
> 
> This option is useful for bonding modes balance-rr (0), active-backup
> (1), balance-tlb (5) and balance-alb (6), in which a failover can switch
> the IGMP traffic from one slave to another.  Therefore a fresh IGMP
> report must be issued to cause the switch to forward the incoming
> IGMP traffic over the newly selected slave.
> 
> What do you think?

I'm find with leaving it generic.

rick jones

