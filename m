From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Thu, 23 Aug 2012 18:44:24 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD34488DD379@ORSMSX101.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EEA@ORSMSX105.amr.corp.intel.com>
 <20120823181117.GD2192@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18913 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030674Ab2HWSpy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 14:45:54 -0400
In-Reply-To: <20120823181117.GD2192@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, August 23, 2012 11:11 AM
> To: Keller, Jacob E
> Cc: Vick, Matthew; Kirsher, Jeffrey T; davem@davemloft.net;
> netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 11/13] igb: Update PTP function names/variables
> and locations.
> 
> [...]
> 
> Relative, high resolution time stamps can be interesting all by
> themselves. That is why wireshark has a whole menu of timing choices
> including relative since start, inter-packet, and so on.
> 
> [...]
> 
> Yes, I agree that igb is a bit oddly synced WRT clock and time
> stamping. I would welcome a change to let it have HW time stamping as
> an independent feature.
> 
> Thanks,
> Richard

Isn't this discussion creeping outside the scope of this patch? My aim here with this patch is to help tidy up PTP code as it is today. As it is today, igb has no support for hardware timestamping without PTP. If you or someone else writes a follow-on patch to add hardware timestamping without PTP, then they can move and rename the functions accordingly (and I'd personally really appreciate it if they did rename it, since a generic function should be named like a generic function and a PTP function should be named like a PTP function).

Cheers,
Matthew 
