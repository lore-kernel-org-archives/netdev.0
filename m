From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Thu, 13 Sep 2007 14:02:57 -0700
Message-ID: <adatzpyl1mm.fsf@cisco.com>
References: <adahclymos8.fsf@cisco.com>
	<000401c7f632$c993e8e0$65cc180a@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <general@lists.openfabrics.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "Sean Hefty" <sean.hefty@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:46028 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247AbXIMVDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 17:03:06 -0400
In-Reply-To: <000401c7f632$c993e8e0$65cc180a@amr.corp.intel.com> (Sean Hefty's message of "Thu, 13 Sep 2007 11:20:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > - My user_mad P_Key index support patch.  I'll test the ioctl to
 > >   change to the new mode and merge this I guess, since Hal and Sean
 > >   have tested this out.
 > 
 > I can give this patch a reviewed-by: too, and I will also try to review a couple
 > of the pending ipoib patches.

Thanks!

 > > - Sean's QoS changes.  These look fine at first glance, and I just
 > >   plan to understand the backwards compatibility story (ie how this
 > >   works with an old SM) and merge.  Anyone who objects let me know.
 > 
 > The new QoS fields fall into fields that are currently reserved, which should be
 > ignored by an older SM.  I've only tested this against openSM however.

That seems OK -- I'm OK with breaking things if an SM is clearly buggy
(and not ignoring fields that are defined to be ignored in the spec
would certainly be a clear bug to me).

 > This patch was generated in response to an Intel MPI issue.  We've seen MPI take
 > several minutes to respond to a connection request during the middle of large
 > application runs.  When this happens, the active side times out the connection.
 > In OFED, we added module parameters to adjust the rdma_cm connection timeout on
 > the active side, but I believe that sending an MRA from the passive side is a
 > better solution.

OK -- just to make sure I'm understanding what you're saying: have you
confirmed that your proposed patches actually fix the issue?

 - R.
