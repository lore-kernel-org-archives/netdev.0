From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Thu, 23 Aug 2012 18:58:06 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD34488DD3D6@ORSMSX101.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD32D@ORSMSX101.amr.corp.intel.com>
 <02874ECE860811409154E81DA85FBB5807857FFC@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57968 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934225Ab2HWS6X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 14:58:23 -0400
In-Reply-To: <02874ECE860811409154E81DA85FBB5807857FFC@ORSMSX105.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Keller, Jacob E
> Sent: Thursday, August 23, 2012 11:48 AM
> To: Vick, Matthew; Richard Cochran
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: RE: [net-next 11/13] igb: Update PTP function names/variables
> and locations.
> 
> [...]
> 
> The history isn't lost, it is just obscured. I agree if the change is
> necessary it should be done. I think we all disagree on what is
> necessary. I would prefer function names to match. Richard has a point
> regarding the time stamping all packets, however again the ioctl
> turning that on tends to be quite PTP centric already. I think that
> value isn't necessarily added due to the current coupling of the
> features. It is partially coupled by the hardware anyways.
> 
> Effectively with the PTP framework disabled you have a half useful
> feature that is enabled by a strange ioctl that has a lot of PTP
> specific names, and doesn't always do what you want.
> 
> I am not sure how much work would be required to get to a state where
> the separation of function makes sense.
> 
> - Jake

Fair point about the history.

Since these functions are tightly coupled with PTP, it makes sense to call them that for now. Long-term, I completely agree with Richard--once the function is independent of PTP, we should give it a generic name. 

Cheers,
Matthew
