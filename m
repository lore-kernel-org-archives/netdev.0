From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 28 Jul 2006 01:21:50 -0700 (PDT)
Message-ID: <20060728.012150.45740322.davem@davemloft.net>
References: <1153979173.6904.100.camel@localhost.localdomain>
	<20060726.230028.00077989.davem@davemloft.net>
	<20060727115419.0e25843f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17031
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932594AbWG1IWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 04:22:11 -0400
To: shemminger@osdl.org
In-Reply-To: <20060727115419.0e25843f@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 27 Jul 2006 11:54:19 -0700

> I think we sell our existing stack short.

I agree.

> There are lots of opportunities left to look more closely at actual
> real performance bottlenecks and improve incrementally. But it
> requires, tools, time, faster net hardware, and some creative
> insight. I guess it just isn't as cool.

We are in fact suggesting some ideas that address the current
stack issues along the way.  Witness the discussion we had about
the tcp_ack() costs wrt. pruning the retransmit queue and tagging
packets for SACK, I'm working on a new data structure and layout
to cure all that stuff.

But I think we can do better.  Jamal said to me one email, "If even
only half of Van's numbers are real, this is really exciting."

Rusty and Alexey are looking at the problem from another direction.
Go back to the unified flow cache, implement all the hair to do
that, and then we can look at netchannels because they will be so
much more straight forward at that point.
