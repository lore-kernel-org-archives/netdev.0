From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP stalls with 802.3ad + bridge + kvm guest
Date: Sat, 11 Aug 2012 11:28:40 -0700
Message-ID: <20120811112840.0dc9ba71@nehalam.linuxnetplumber.net>
References: <20120727183840.GE17572@p12n.org>
	<26496.1343419205@death.nxdomain>
	<20120801144104.GN17572@p12n.org>
	<CAEuXFExg2X9r0zE8wUs9Npd7jPUN2WHbyJcnH6eT_23f2DoPjw@mail.gmail.com>
	<20120804162219.GT17572@p12n.org>
	<20120804224511.GU17572@p12n.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	jgoerzen@efolder.net
To: Peter Samuelson <psamuelson@efolder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44559 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998Ab2HKS2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Aug 2012 14:28:54 -0400
In-Reply-To: <20120804224511.GU17572@p12n.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 4 Aug 2012 17:45:11 -0500
Peter Samuelson <psamuelson@efolder.net> wrote:

> 
> > [Jesse Brandeburg]
> > > try
> > > # ethtool -K ethx tso off gso off lro off
> 
> Specifically, 'lro off' is the trick.  The others don't have a
> noticeable effect.  Now I can get 70 MB/s or better most of the time,
> in either direction.
> 
> Thanks again,
> Peter

When device is added to bridge, the bridge code does ask the device
to turn LRO off (automatically). Unfortunately some device drivers are
broken.
