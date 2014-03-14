From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RCU PATCH 06/14] net: sched: fw use RCU
Date: Fri, 14 Mar 2014 08:38:11 -0700
Message-ID: <20140314153810.GX21124@linux.vnet.ibm.com>
References: <20140310170546.3011.82918.stgit@nitbit.x32>
 <1394473279.3607.46.camel@edumazet-glaptop2.roam.corp.google.com>
 <53208E3F.5090401@gmail.com>
 <1394643673.21721.48.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140313202245.GK21124@linux.vnet.ibm.com>
 <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140313211509.GP21124@linux.vnet.ibm.com>
 <53229704.1040808@gmail.com>
 <20140314132834.GS21124@linux.vnet.ibm.com>
 <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:57740 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644AbaCNPiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 11:38:17 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 14 Mar 2014 09:38:17 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 106571FF003B
	for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 09:38:14 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2EFbYEs11075996
	for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 16:37:34 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s2EFflEh018110
	for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 09:41:47 -0600
Content-Disposition: inline
In-Reply-To: <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 06:46:38AM -0700, Eric Dumazet wrote:
> On Fri, 2014-03-14 at 06:28 -0700, Paul E. McKenney wrote:
> 
> > Now I just need to figure out why it -causes- a BUILD_BUG_ON for the
> > cris and m68k architectures in Fengguang Wu's testing...
> 
> Right, they don't necessarily align pointers ;)
> 
> alignof(void *) ?

It complained about the size rather than the alignment, but it would
certainly make sense to constrain the rcu_head structure's alignment,
now that you mention it.  I will do that and see if it helps.  ;-)

Thank you for the tip!

							Thanx, Paul
