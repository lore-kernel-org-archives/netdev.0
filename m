From: Peter Samuelson <psamuelson@efolder.net>
Subject: Re: TCP stalls with 802.3ad + bridge + kvm guest
Date: Sat, 4 Aug 2012 17:45:11 -0500
Message-ID: <20120804224511.GU17572@p12n.org>
References: <20120727183840.GE17572@p12n.org>
 <26496.1343419205@death.nxdomain>
 <20120801144104.GN17572@p12n.org>
 <CAEuXFExg2X9r0zE8wUs9Npd7jPUN2WHbyJcnH6eT_23f2DoPjw@mail.gmail.com>
 <20120804162219.GT17572@p12n.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	jgoerzen@efolder.net
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx11.dcmx.net ([207.210.100.175]:43230 "EHLO mx11.dcmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754050Ab2HDWpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Aug 2012 18:45:15 -0400
Content-Disposition: inline
In-Reply-To: <20120804162219.GT17572@p12n.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> [Jesse Brandeburg]
> > try
> > # ethtool -K ethx tso off gso off lro off

Specifically, 'lro off' is the trick.  The others don't have a
noticeable effect.  Now I can get 70 MB/s or better most of the time,
in either direction.

Thanks again,
Peter
