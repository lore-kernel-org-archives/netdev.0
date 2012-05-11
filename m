From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 07/12] ixgbe: Enable timesync clock-out feature for
 PPS support on X540
Date: Fri, 11 May 2012 18:10:17 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5807794962@ORSMSX105.amr.corp.intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-8-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141721.GC3392@localhost.localdomain>
 <02874ECE860811409154E81DA85FBB5807794293@ORSMSX105.amr.corp.intel.com>
 <20120511054036.GC2170@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:34311 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422636Ab2EKSKT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 14:10:19 -0400
In-Reply-To: <20120511054036.GC2170@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, May 10, 2012 10:41 PM
> To: Keller, Jacob E
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 07/12] ixgbe: Enable timesync clock-out feature for PPS
> support on X540
> 
> On Thu, May 10, 2012 at 10:08:44PM +0000, Keller, Jacob E wrote:
> >
> > Oops stupid mail program sent that on accident. Anyways: I think you
> > might be right, Richard. We don't read those timestamp values unless
> > the stat err bit for timestamps is set on the descriptor. But I am not
> > sure what happens when the tjmestamped packet is dropped off the end
> > of the ring. What would you propose here? How can we detect if this
> > timestamp doesn't match the packet? I can look into using the extra
> > hardware features for matching timestamps. That might be a more useful, in
> that it would help prevent this case.
> 
> [ Talking about the Rx time stamping locking from other patch... ]
> 
> The IGB provides some PTP event packet identification fields (seqNum,
> etc) just for the purpose of matching time stamps to packets. Some of the
> other PHC drivers (ixp4xx, dp83640) have code that does the matching.
> 

Ixgbe has the sequence number also. I'll take a look at the PHC drivers
that match already, and see how difficult it would be to perform this check.

- Jake

> HTH,
> Richard
> 
