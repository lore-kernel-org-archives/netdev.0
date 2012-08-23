From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [net-next 13/13] igb: Store the MAC address in the name in the
 PTP struct.
Date: Thu, 23 Aug 2012 16:05:09 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD34488DD00C@ORSMSX101.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-14-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823104554.GA2238@netboy.at.omicron.at>
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
Received: from mga09.intel.com ([134.134.136.24]:26445 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030574Ab2HWQGI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 12:06:08 -0400
In-Reply-To: <20120823104554.GA2238@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, August 23, 2012 3:46 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Vick, Matthew; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 13/13] igb: Store the MAC address in the name in
> the PTP struct.
> 
> On Thu, Aug 23, 2012 at 02:56:53AM -0700, Jeff Kirsher wrote:
> > From: Matthew Vick <matthew.vick@intel.com>
> >
> > Change the name of the adapter in the PTP struct to enable easier
> > correlation between interface and PTP device.
> 
> You want to put the MAC address into the clock name? This is wrong.
> 
> Besides, there is no need for this. The ethool method already makes the
> correlation crystal clear.
> 
> Thanks,
> Richard

Actually, the name today is wrong. "igb-82580" is inapplicable to I350, I210, and I211 devices. This patch aims to bring some sense to the naming while fixing it. ixgbe implements the same naming scheme.

Cheers,
Matthew
