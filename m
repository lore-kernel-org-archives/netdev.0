From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH net V4 0/2] igb: ptp hardware clock
Date: Fri, 27 Jan 2012 20:42:20 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B2E07B8F1@ORSMSX101.amr.corp.intel.com>
References: <cover.1327161325.git.richardcochran@gmail.com>
 <1327638293.2729.43.camel@jtkirshe-mobl>
 <20120127101119.GA6690@netboy.at.omicron.at>
 <1327659327.2729.55.camel@jtkirshe-mobl>
 <1327659761.2220.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1327661789.2729.57.camel@jtkirshe-mobl>
 <20120127121155.GA5380@cherladcori01>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:32037 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641Ab2A0UmX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:42:23 -0500
In-Reply-To: <20120127121155.GA5380@cherladcori01>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Friday, January 27, 2012 4:12 AM
> To: Kirsher, Jeffrey T
> Cc: Eric Dumazet; Brown, Aaron F; netdev@vger.kernel.org; e1000-
> devel@lists.sourceforge.net; Keller, Jacob E; Ronciak, John; John Stultz;
> Thomas Gleixner
> Subject: Re: [PATCH net V4 0/2] igb: ptp hardware clock
> 
> On Fri, Jan 27, 2012 at 02:56:29AM -0800, Jeff Kirsher wrote:
> > Eric was correct.  I added #include <linux/mdoule.h> to the igb_ptp.c
> > file and the error goes away.
> >
> > Richard are you fine with me adding that change to your first patch of
> > the series?  That way I can have the validation team finish up testing
> > your patches.
> 
> By all means, please go right ahead.
> 
> Thanks,
> Richard
> 

Yes, that does indeed resolve the compilation issue I was seeing in the lab, thanks...  I'm assuming a set of .config files that were failing is no longer necessary.
