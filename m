From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net-next-2.6: SYN retransmits: Rename threshold
 variable
Date: Thu, 30 Sep 2010 17:23:37 -0700 (PDT)
Message-ID: <20100930.172337.220062330.davem@davemloft.net>
References: <1285703144.7187.4.camel@nexus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53513
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752632Ab0JAAXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 20:23:16 -0400
In-Reply-To: <1285703144.7187.4.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Damian please don't do things like this.

When we make a change in net-2.6, that change is going to propagate into
net-next-2.6 the next time I do a merge.

And in this case here, the addition of the "syn_set" boolean argument to
retransmits_timed_out() will happen at that point.

So if anything, you should build on top of the bug fix we put into
net-2.6 instead of duplicating the change.

Adding the same change in two different ways to net-2.6 and net-next-2.6
makes the merge a pain in the neck for me and just makes things look
real confusing.

I'm not applying these two patches, please ask me to merge net-2.6 into
net-next-2.6 and this way you can code them relative to that.

Thanks!
