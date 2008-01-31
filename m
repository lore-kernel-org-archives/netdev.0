From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 09:57:40 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801310955040.10967@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>
 <20080130.055333.192844925.davem@davemloft.net>
 <Pine.LNX.4.63.0801300758020.11487@trinity.phys.uwm.edu>
 <20080130082136.1017631d@deepthought> <Pine.LNX.4.63.0801301610240.19938@trinity.phys.uwm.edu>
 <649aecc70801301617m6331bcb8i8ce60366e182c739@mail.gmail.com>
 <20080131064533.ef0ae932.billfink@mindspring.com> <47A1E026.2070805@roinet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Bill Fink <billfink@mindspring.com>,
	SANGTAE HA <sangtae.ha@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: David Acker <dacker@roinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:47475 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758666AbYAaP6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 10:58:14 -0500
In-Reply-To: <47A1E026.2070805@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> Could this be an issue with pause frames?  At a previous job I remember 
> having issues with a similar configuration using two broadcom sb1250 3 
> gigE port devices. If I ran bidirectional tests on a single pair of 
> ports connected via cross over, it was slower than when I gave each 
> direction its own pair of ports.  The problem turned out to be that 
> pause frame generation and handling was not configured correctly.

We had PAUSE frames turned off for our testing.  The idea is to let TCP 
do the flow and congestion control.

The problem with PAUSE+TCP is that it can cause head-of-line blocking, 
where a single oversubscribed output port on a switch can PAUSE a large 
number of flows on other paths.

Cheers,
 	Bruce
