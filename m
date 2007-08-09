From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Thu, 09 Aug 2007 10:49:35 -0700
Message-ID: <adawsw4mwcw.fsf@cisco.com>
References: <20070807.160651.98554604.davem@davemloft.net>
	<OFA2F18805.38AA0BD0-ON87257331.005367FB-88257331.0027BEED@us.ibm.com>
	<20070808.152059.101495015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xma@us.ibm.com, hadi@cyberus.ca, jgarzik@pobox.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	rusty@rustcorp.com.au, shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:14639 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbXHIRtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 13:49:42 -0400
In-Reply-To: <20070808.152059.101495015.davem@davemloft.net> (David Miller's message of "Wed, 08 Aug 2007 15:20:59 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > Dave, could you please hold this portion of the patch for a moment. I will
 > > test this patch ASAP. According to our previous experience, this changes
 > > significant changes some IPoIB driver performance.
 > 
 > I reverted everything Roland had an issue with, I got tired of arguing
 > my position and doing all of the coding too.  He won.

Why does this have to become a contest of wills where someone wins?  I
wish we could just have a technical discussion and get to the best
solution.  You posted an RFC, and I commented on the parts where I
believe I have some expertise.  We're all on the same side here.

Shirley, I think it would still be useful to run benchmarks of IPoIB
on ehca with Dave's NAPI patches, both V5 that changed the "missed
event" behavior and V6 that didn't.  At least I'm curious to know how
much the difference is.

 - R.
