From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] addition of a dropped packet notification service
Date: Wed, 25 Feb 2009 14:07:01 -0800 (PST)
Message-ID: <20090225.140701.42567297.davem@davemloft.net>
References: <20090225115419.GA16150@hmsreliant.think-freely.org>
	<20090225.040130.169376412.davem@davemloft.net>
	<20090225141841.GD16150@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, shemminger@vyatta.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43194
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751916AbZBYWHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 17:07:18 -0500
In-Reply-To: <20090225141841.GD16150@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 25 Feb 2009 09:18:41 -0500

> On Wed, Feb 25, 2009 at 04:01:30AM -0800, David Miller wrote:
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Wed, 25 Feb 2009 06:54:19 -0500
> > 
> > And you need the same thing to extract the same information
> > if you used tracepoints.
>
> Well, I think the above implementation can be done with or without
> tracepoints.  The mechanism by which we get the drop information is
> orthogonal to what we do with it.
> 
> Thanks for the feedback guys.  I'll start modifying my kernel
> changes to reflect this striaght away.  If you'd like to see
> something in the interim, let me know and I'll send you what I have.
> Currently I've got the user space delivery mechanism working as a
> Netlink protocol, and with your above suggestions, I expect to have
> the drop capture piece recode and working in the next few weeks.

Don't get me wrong.

If tracepoint annotations can be manageable (Herbert's concern), and
solve multiple useful problems in practice rather than just
theoretically (my concern), then that's what we should use for this
kind of stuff.

I just personally haven't been convinced of that yet.
