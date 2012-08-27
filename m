From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Mon, 27 Aug 2012 15:23:43 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD34488DEF86@ORSMSX101.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EEA@ORSMSX105.amr.corp.intel.com>
 <20120823181117.GD2192@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD379@ORSMSX101.amr.corp.intel.com>
 <20120824065554.GB3261@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DDE99@ORSMSX101.amr.corp.intel.com>
 <20120825054846.GA2233@netboy.at.omicron.at>
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
Received: from mga11.intel.com ([192.55.52.93]:65114 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441Ab2H0PXp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 11:23:45 -0400
In-Reply-To: <20120825054846.GA2233@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Friday, August 24, 2012 10:49 PM
> To: Vick, Matthew
> Cc: Keller, Jacob E; Kirsher, Jeffrey T; davem@davemloft.net;
> netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 11/13] igb: Update PTP function names/variables
> and locations.
> 
> On Fri, Aug 24, 2012 at 03:52:30PM +0000, Vick, Matthew wrote:
> >
> > Looking over the discussions and by trying to reach consensus, I
> think what I will do is re-spin patch 3 that Jeff sent (Correct PTP
> support query from ethtool.) to V2 with your feedback and work with
> Jeff to send all of my patchset up together. This first group of
> patches is groundwork for the last two. How does this sound?
> 
> Sound good to me.
> 
> BTW, if you have some bug fixes coming (like ifup/ifdown), please put
> them *before* any other renaming/refactoring. In that way, the bug fix
> can do directly to 3.5 stable, too.
> 
> Thanks,
> Richard

Unfortunately, the way I've built the series makes it difficult to put those fixes before the re-factoring. The need for the design change drove the re-factor to give me the foundation. I'll make a note to myself to come up with something to apply to stable.

Cheers,
Matthew 
