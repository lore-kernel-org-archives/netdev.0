From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 15:39:24 -0800
Message-ID: <20091113153924.6130135f@nehalam>
References: <200911130701.14847.opurdila@ixiacom.com>
	<4AFCF8D3.6090905@gmail.com>
	<20091112222608.79d90e9e@nehalam>
	<200911131151.31677.opurdila@ixiacom.com>
	<20091113142939.35879efe@s6510>
	<20091113224043.GP19478@kvack.org>
	<20091113144937.23693bb4@nehalam>
	<20091113233504.GQ19478@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57937 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932571AbZKMXjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:39:39 -0500
In-Reply-To: <20091113233504.GQ19478@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 18:35:04 -0500
Benjamin LaHaise <bcrl@lhnet.ca> wrote:

> On Fri, Nov 13, 2009 at 02:49:37PM -0800, Stephen Hemminger wrote:
> > Then maybe network devices aren't the right layering model. At some
> > point the paradigm has to be re-examined.
> 
> What is the right model for dealing with lots of connections to users and 
> routes?  This problem isn't going to go away given the increases in 
> connectivity and processing power that happen each year.  Today, software 
> routing of 10Gbps links is a reality -- part of what comes with that ability 
> of hardware is the need to deal with the fact that 10Gbps aggregates a lot 
> of users.
> 
> 		-ben

Well TCP handles lots of connections, but a socket has different overhead
than a network device. Why should 10Gbps need 10K PPPoE sessions?
Even Vlan's are less overhead than PPP

-- 
