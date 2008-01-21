From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: add sparse annotation to ptype_seq_start/stop
Date: Sun, 20 Jan 2008 22:01:19 -0800
Message-ID: <20080121060119.GE7541@linux.vnet.ibm.com>
References: <20080120152146.70bc0b12@deepthought> <20080121050355.GD7541@linux.vnet.ibm.com> <20080121052831.GF27894@ZenIV.linux.org.uk>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@freedesktop.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:53576 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbYAUGB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 01:01:29 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0L61TPj029045
	for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 01:01:29 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0L61LNI095854
	for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 23:01:22 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0L61L8O026397
	for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 23:01:21 -0700
Content-Disposition: inline
In-Reply-To: <20080121052831.GF27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 05:28:31AM +0000, Al Viro wrote:
> On Sun, Jan 20, 2008 at 09:03:55PM -0800, Paul E. McKenney wrote:
> > On Sun, Jan 20, 2008 at 03:21:46PM -0800, Stephen Hemminger wrote:
> > > Get rid of some more sparse warnings.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > Adding Josh to CC -- is __acquires() case-insensitive?  If not, this
> > needs to be __acquires(RCU) and __releases(RCU).
> 
> __acquires(whatever_the_helk_you_put_as_its_argument) is all the same.

The existing calls are __acquires(RCU) and __releases(RCU).  I suppose
that one -could- use __acquires(RCU) in some places and __acquires(rcu)
in others, but that sounds like it would eventually bite us...

							Thanx, Paul
