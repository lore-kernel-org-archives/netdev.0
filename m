From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 16:35:12 -0700
Message-ID: <adatze7x7wv.fsf@cisco.com>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
	<20080730133727.7774de6a@extreme> <20080730224849.59852c68@surf>
	<20080730140136.42223e3c@extreme> <20080730233551.76fd38a8@surf>
	<20080730144812.a71156f7.akpm@linux-foundation.org>
	<20080730235231.71f1b2f9@surf>
	<20080730150454.7612912f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	shemminger@vyatta.com, jeff@garzik.org, netdev@vger.kernel.org,
	davem@davemloft.net, mpm@selenic.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:45366 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757313AbYG3XfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:35:14 -0400
In-Reply-To: <20080730150454.7612912f.akpm@linux-foundation.org> (Andrew
	Morton's message of "Wed, 30 Jul 2008 15:04:54 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > I don't really trust allnoconfig as a way of determining size changes. 
 > It can easily be the case that kernel A's allnoconfig happens to pull
 > in more stuff than kernel B's allnoconfig.
 > 
 > So I do think that one should dive into the details and verify that
 > particular size changes really are due to unavoidable code bloat,
 > rather than being due to some unfortunate Kconfig change.

The following is rather squishy, but... when I've looked at the growth
of various bits of the kernel over time, a good bit of the growth comes
from changes like "add handling for undeniably useful feature X" or "add
handling of error condition Y."  And it's 50 bytes here, 100 bytes
there, and all the changes make sense and are too small to make
configurable.  So being able to get 6K all at once from ethtool is
actually pretty good, although probably not quite good enough to merge.

I really don't know what the right answer is to all of this.
