From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Wed, 9 Mar 2011 09:56:59 -0800
Message-ID: <20110309095659.1373c296@s6510>
References: <il4vur$3ka$1@dough.gmane.org>
	<20110308111011.GA27967@xanadu.blop.info>
	<4D764AAC.30302@ncsu.edu>
	<20110308.114346.48506864.davem@davemloft.net>
	<20110308152103.714f5f05@nehalam>
	<4D76D851.4050600@ncsu.edu>
	<20110309065319.GA23740@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Injong Rhee <rhee@ncsu.edu>, David Miller <davem@davemloft.net>,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	sangtae.ha@gmail.com
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35182 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757128Ab1CIR5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 12:57:03 -0500
In-Reply-To: <20110309065319.GA23740@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Mar 2011 07:53:19 +0100
Lucas Nussbaum <lucas.nussbaum@loria.fr> wrote:

> On 08/03/11 at 20:30 -0500, Injong Rhee wrote:
> > Now, both tools can be wrong. But that is not catastrophic since
> > congestion avoidance can kick in to save the day. In a pipe where no
> > other flows are competing, then exiting slow start too early can
> > slow things down as the window can be still too small. But that is
> > in fact when delays are most reliable. So those tests that say bad
> > performance with hystart are in fact, where hystart is supposed to
> > perform well.
> 
> Hi,
> 
> In my setup, there is no congestion at all (except the buffer bloat).
> Without Hystart, transferring 8 Gb of data takes 9s, with CUBIC exiting
> slow start at ~2000 packets.
> With Hystart, transferring 8 Gb of data takes 19s, with CUBIC exiting
> slow start at ~20 packets.
> I don't think that this is "hystart performing well". We could just as
> well remove slow start completely, and only do congestion avoidance,
> then.
> 
> While I see the value in Hystart, it's clear that there are some flaws
> in the current implementation. It probably makes sense to disable
> hystart by default until those problems are fixed.


What is the speed and RTT time of your network?
I think you maybe blaming hystart for other issues in the network.
