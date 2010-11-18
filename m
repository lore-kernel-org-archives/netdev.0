From: Sonny Rao <sonnyrao@us.ibm.com>
Subject: Re: [PATCH] qlge: Fix incorrect usage of module parameters and
	netdev msg level
Date: Thu, 18 Nov 2010 17:12:12 -0600
Message-ID: <20101118231212.GU32203@us.ibm.com>
References: <20101118215002.GS32203@us.ibm.com>
 <20101118221713.GB14333@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: ron.mercer@qlogic.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Milton Miller <miltonm@bga.com>,
	Linux Driver <Linux-Driver@qlogic.com>,
	"linux-kernel@vger.kernel.org" <lin
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:49658 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758239Ab0KRXMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 18:12:15 -0500
Content-Disposition: inline
In-Reply-To: <20101118221713.GB14333@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 18, 2010 at 02:17:14PM -0800, Ron Mercer wrote:
> On Thu, Nov 18, 2010 at 01:50:02PM -0800, Sonny Rao wrote:
> > Driver appears to be mistaking the permission field with default value
> > in the case of debug and qlge_irq_type.
> > 
> > Driver is also passing debug as a bitmask into netif_msg_init()
> > which wants a number of bits.  Ron Mercer suggests we should
> > change this to pass in -1 so the defaults get used instead,
> > which makes the default much less verbose.
> > 
> > Signed-off-by: Milton Miller <miltonm@bga.com>
> > Signed-off-by: Sonny Rao <sonnyrao@linux.vnet.ibm.com>
> 
> Milton/Sonny,
> Did you happen to test this to see if the log output was the same? 

Well, I haven't tried the -1 but I suspect it is much more sane than
the 15 I had before because that was excessively verbose and I always
ended up turning it down.  I'll try it out and see.

-- 
Sonny Rao, LTC OzLabs, BML team
