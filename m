From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Mon, 27 Aug 2012 17:39:45 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD34488DF198@ORSMSX101.amr.corp.intel.com>
References: <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EEA@ORSMSX105.amr.corp.intel.com>
 <20120823181117.GD2192@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD379@ORSMSX101.amr.corp.intel.com>
 <20120824065554.GB3261@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DDE99@ORSMSX101.amr.corp.intel.com>
 <20120825054846.GA2233@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DEF86@ORSMSX101.amr.corp.intel.com>
 <20120827164428.GA2269@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:48565 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753767Ab2H0Rjr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 13:39:47 -0400
In-Reply-To: <20120827164428.GA2269@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Monday, August 27, 2012 9:44 AM
> To: Vick, Matthew
> Cc: Keller, Jacob E; Kirsher, Jeffrey T; davem@davemloft.net;
> netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 11/13] igb: Update PTP function names/variables
> and locations.
> 
> >
> > Unfortunately, the way I've built the series makes it difficult to
> put those fixes before the re-factoring. The need for the design change
> drove the re-factor to give me the foundation. I'll make a note to
> myself to come up with something to apply to stable.
> 
> Hm, I didn't see anything here that looks like bug fix. Did I miss
> something?  What causes the ifup/ifdown weirdness, anyhow?
> 
> (It seems hard to believe that it has something to do with the names or
> locations of the various functions.)
> 
> Thanks,
> Richard

Sorry, I wasn't very clear--I mean the bug fix I have for ifup/ifdown is in the next few patches with the implementation change I'm doing, since the code I have in place to fix it applies only to the new implementation. I'll have to make a separate patch for stable to address it there.

If the ifup/ifdown weirdness happens because we never re-enable timestamping in the hardware following reset and the device goes through a reset during an ifdown/ifup cycle. It's a pretty straightforward fix, so it shouldn't be much effort to spin up something for stable.

Matthew
