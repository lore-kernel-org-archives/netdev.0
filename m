From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [RFT PATCH] pcnet32:  NAPI support
Date: Wed, 28 Jun 2006 09:55:41 -0700
Message-ID: <20060628165541.GA16601@us.ibm.com>
References: <20060623213212.GA24388@us.ibm.com> <20060628144010.GA1446@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:61075 "EHLO
	e34.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751454AbWF1Q4t
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 12:56:49 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5SGumsR003229
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 28 Jun 2006 12:56:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5SGv5UT188112
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 28 Jun 2006 10:57:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5SGulA1030831
	for <netdev@vger.kernel.org>; Wed, 28 Jun 2006 10:56:48 -0600
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Content-Disposition: inline
In-Reply-To: <20060628144010.GA1446@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 28, 2006 at 10:40:10AM -0400, Lennart Sorensen wrote:
> On Fri, Jun 23, 2006 at 02:32:12PM -0700, Don Fry wrote:
> > This set of changes combines the work done by Len Sorensen and myself to
> > add compile time support for NAPI for the pcnet32 driver.  I have tested
> > it on ia32 and ppc64 hardware with various versions of the pcnet32
> > adapter.  I have also made a few changes requested by Jon Mason, but the
> > substitution of the many magic numbers in the driver is not yet done.
> > 
> > If no-one encounters any problems when testing this, I will break up the
> > several changes, into proper patches and submit them next week.
> 
> Well so far this is working for me.  It is a somewhat different layout
> of the interrupt handler so it took me a bit of work to get the features
> I need patched in, but in the end I ended up with simpler code as a
> reesult, so I am quite happy with the new layout.  The driver works on
> everything I have to try it on so far.
> 

<snip>

Yes, I saw the debug statements when creating the email and was too lazy
to remove them and create a new patch.  The patch needs to be broken up
into functional pieces anyway, so since it has passed all of my testing
as well, I will start on that...

> 
> So yep, looks pretty good to me.  Those two debug statements are my only
> comments on it.
> 
> Len Sorensen

-- 
Don Fry
brazilnut@us.ibm.com
