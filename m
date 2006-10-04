From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Wed, 04 Oct 2006 02:08:06 -0700 (PDT)
Message-ID: <20061004.020806.41635871.davem@davemloft.net>
References: <4522A88E.2070200@redhat.com>
	<20061004.000722.99203823.davem@davemloft.net>
	<200610041056.12704.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: woodard@redhat.com, netdev@vger.kernel.org, mgrondona@llnl.gov,
	behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41447
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161178AbWJDJII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 05:08:08 -0400
To: netdev@axxeo.de
In-Reply-To: <200610041056.12704.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Oeser <netdev@axxeo.de>
Date: Wed, 4 Oct 2006 10:56:12 +0200

> David Miller wrote:
> > At the very least, seconds might not be fine enough granularity
> > for some circumstances.  Heck, the default RTO_MIN is 1/5 of a
> > second. :-)
> > 
> > I also understand that going to milliseconds or microseconds would
> > make the size of the in-socket struct members an issue again.  These
> > things are never easy are they? :-/
> 
> Would be, if floating point values would be allowed. Single precision would 
> be enough in this case and its just 32 bits IIRC.
> 
> I mean floating point values just for the user->kernel ABI and 
> NOT for the internal timer representation.

We got the struct members down to 16-bits each, the problem is in
fact that we'd need to make them 32-bits again.
