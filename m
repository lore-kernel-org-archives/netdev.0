From: Rick Jones <rick.jones2@hp.com>
Subject: Re: error(s) in 2.6.23-rc5 bonding.txt ?
Date: Fri, 07 Sep 2007 16:46:54 -0700
Message-ID: <46E1E2EE.7080202@hp.com>
References: <46E1CA81.6050808@hp.com> <32121.1189207861@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:38119 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483AbXIGXrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 19:47:31 -0400
In-Reply-To: <32121.1189207861@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 	That said, it's certainly plausible that, for a given set of N
> ethernets all enslaved to a single bonding balance-rr, the individual
> ethernets could get out of sync, as it were (e.g., one running a fuller
> tx ring, and thus running "behind" the others). 

That is the scenario of which I was thinking.

> If bonding is the only feeder of the devices, then for a continuous
> flow of traffic, all the slaves will generally receive packets (from
> the kernel, for transmission) at pretty much the same rate, and so
> they won't tend to get ahead or behind.

I could see that if there was just one TCP connection going doing bulk 
or something, but if there were a bulk transmitter coupled with an 
occasional request/response (ie netperf TCP_STREAM and a TCP_RR) i'd 
think the tx rings would no longer remain balanced.

> 	I haven't investigated into this deeply for a few years, but
> this is my recollection of what happened with the tests I did then.  I
> did testing with multiple 100Mb devices feeding either other sets of
> 100Mb devices or single gigabit devices.  I'm willing to believe that
> things have changed, and an N feeding into one configuration can
> reorder, but I haven't seen it (or really looked for it; balance-rr
> isn't much the rage these days).

Are you OK with that block of text simply being yanked?

rick
