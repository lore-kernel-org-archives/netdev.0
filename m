From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 23 Aug 2012 16:27:27 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD34488DD0B9@ORSMSX101.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823112837.GE2238@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11556 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751519Ab2HWQ1u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 12:27:50 -0400
In-Reply-To: <20120823112837.GE2238@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, August 23, 2012 4:29 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Vick, Matthew; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
> 
> On Thu, Aug 23, 2012 at 02:56:50AM -0700, Jeff Kirsher wrote:
> > From: Matthew Vick <matthew.vick@intel.com>
> >
> > For users without CONFIG_IGB_PTP=y, we should not be compiling any
> PTP
> > code into the driver. Tidy up the wrapping in igb to support this.
> 
> I would appreciate being put on Cc: for any PTP stuff.
> 
> Also, if you really want to improve the IGB driver, maybe you could
> look at what happens to the time stamping when you do an ifdown/ifup on
> the card. It seems to screw everything (observed on kernel 3.5).
> 
> Thanks,
> Richard

Will do going forward. I appreciate the review.

I actually have two patches coming up that bring some further improvements--these first couple patches are foundation for those. In a patch coming up, the ifdown/ifup issue gets resolved.

Cheers,
Matthew
