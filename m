From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Thu, 27 Jul 2006 11:54:19 -0700
Message-ID: <20060727115419.0e25843f@localhost.localdomain>
References: <1153966671.6904.71.camel@localhost.localdomain>
	<20060726.221708.123400049.davem@davemloft.net>
	<1153979173.6904.100.camel@localhost.localdomain>
	<20060726.230028.00077989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:29617 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751948AbWG0Sy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 14:54:58 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060726.230028.00077989.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Jul 2006 23:00:28 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Thu, 27 Jul 2006 15:46:12 +1000
> 
> > Yes, my first thought back in January was how netfilter would interact
> > with this in a sane way.  One answer is "don't": once someone registers
> > on any hook we go into slow path.  Another is to run the hooks in socket
> > context, which is better, but precludes having the consumer in
> > userspace, which still appeals to me 8)
> 
> Small steps, small steps.  I have not ruled out userspace TCP just
> yet, but we are not prepared to go there right now anyways.  It is
> just the same kind of jump to go to kernel level netchannels as it is
> to go from kernel level netchannels to userspace netchannel based TCP.

I think we sell our existing stack short. There are lots of opportunities left
to look more closely at actual real performance bottlenecks and improve
incrementally. But it requires, tools, time, faster net hardware, and some
creative insight. I guess it just isn't as cool.
