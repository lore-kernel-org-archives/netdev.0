From: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Subject: Re: [PATCH] pcnet32 driver NAPI support
Date: Thu, 8 Jun 2006 11:44:15 -0400
Message-ID: <20060608154415.GC558@csclub.uwaterloo.ca>
References: <20060607165225.GB7859@csclub.uwaterloo.ca> <20060607182040.GA12748@us.ibm.com> <20060607193456.GN7857@csclub.uwaterloo.ca> <20060607215236.GA13380@us.ibm.com> <20060607223245.GA13584@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:47056 "EHLO
	caffeine.csclub.uwaterloo.ca") by vger.kernel.org with ESMTP
	id S964883AbWFHPoP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 11:44:15 -0400
To: Don Fry <brazilnut@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060607223245.GA13584@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2006 at 03:32:45PM -0700, Don Fry wrote:
> One other problem I ran into.  I applied the patch but it will not
> compile because rl_active is never defined.  I have worked around it but

Doh!  I thought I cleaned up all my "weird code" from my own version.
Because of the platform I work with having 4 pcnet32 ports, and a slow
poke 266MHz geode, we can't handle full traffic load, so to keep the
system responsive to pause processing receives when we pass a certain
number of packets per second.  rl_active is part of that.  I meant to
remove all of it, apparently I didn't read every line of my patch
carefully enough. :(

Well at least this ought to clean up my work a bit.

Len Sorensen
