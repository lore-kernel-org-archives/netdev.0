From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: net-next: 2.6.34-rc1 regression: panic when running diagnostic
 on interface with IPv6
Date: Thu, 8 Apr 2010 17:54:44 -0700
Message-ID: <20100408175444.1e0da2c6@nehalam>
References: <EA929A9653AAE14F841771FB1DE5A1365FE4E2E26C@rrsmsx501.amr.corp.intel.com>
	<20100405.161221.159637463.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365FE4E2E334@rrsmsx501.amr.corp.intel.com>
	<20100405.165317.89399272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39284 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754613Ab0DIFnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Apr 2010 01:43:19 -0400
In-Reply-To: <20100405.165317.89399272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 05 Apr 2010 16:53:17 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> Date: Mon, 5 Apr 2010 17:50:38 -0600
> 
> > David Miller wrote:
> >> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> >> Date: Mon, 5 Apr 2010 17:03:56 -0600
> >> 
> >>> David Miller wrote:
> >>>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> >>>> Date: Tue, 23 Mar 2010 12:28:08 -0600
> >>>> 
> >>>>> Bisecting points to this patch:
> >>>>> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=84e8b803f1e16f3a2b8b80f80a63fa2f2f8a9be6
> >>>>> 
> >>>>> And I confirmed that the issue goes away after reverting it.
> >>>>> 
> >>>>> Steps to reproduce:
> >>>>> 1. Load the driver and configure IPv6 address.
> >>>>> 2. Run ethtool diag:
> >>>>> ethtool -t eth0
> >>>>> 
> >>>>> 3. If this doesn't brake it try again, or just do ifdown/up. Other
> >>>>> operations on the interface will eventually panic the system:
> >>>> 
> >>>> Stephen please fix this, thanks.
> >>> 
> >>> Just FYI - I still see this issue with latest pull from net-2.6.
> >> 
> >> It's net-next-2.6 that introduced the problem and has the follow-on
> >> fixes, not net-2.6
> > 
> > Same in net-next:
> 
> Ok, Stephen please look into this, we've had this regression
> for almost two weeks now.

I can't reproduce it, on e1000e.
Since the symptoms match the original problem that you already fixed,
I have to assume that it is fixed but the reporter (Emil) had not
updated his kernel correctly.
