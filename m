From: David Miller <davem@davemloft.net>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Thu, 06 May 2010 00:10:32 -0700 (PDT)
Message-ID: <20100506.001032.245396059.davem@davemloft.net>
References: <4BE1907F.40903@hp.com>
	<20100505.150008.102542618.davem@davemloft.net>
	<4BE2205A.3050900@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, enh@google.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39204
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751191Ab0EFHK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:10:26 -0400
In-Reply-To: <4BE2205A.3050900@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 05 May 2010 21:50:18 -0400

> David Miller wrote:
>> From: Brian Haley <brian.haley@hp.com>
>> Date: Wed, 05 May 2010 11:36:31 -0400
>> 
>>> I now see that in Elliot's email, but I think it's incorrect.  The RFC
>>> says that setting it to -1 should get you the kernel default, which is
>>> now 1.  Without this change, setting it to -1 will get you 64, the
>>> old behavior.  If the user wants to, they can always just set it to
>>> 64 themselves, that's better than assuming when you set it to -1
>>> you're going to get 64.
>> 
>> It's not 64, it's whatever the per-route metric is.
> 
> Not unless that metric's been set via RTAX_HOPLIMIT (and I believe
> this is the unicast hop limit value anyways), and that metric
> defaults to -1.

Right, if it is, and anyone who does set it and expects the default
multicast hop limit to follow along have no portable way to code their
application in a way that works before and after fixing the RFC
issues.

I gave them a way, by making explicit setting of "-1" do what it's
always done.

> At this point in time I'll gladly implement a per-interface sysctl
> to end this discussion.

The game is over, the result decided, and this is just post-game
discussion as far as I'm concerned. :-)

