From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [net-next 12/13] igb: Correct PTP support query from ethtool.
Date: Thu, 23 Aug 2012 16:38:50 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD34488DD103@ORSMSX101.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-13-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823112426.GD2238@netboy.at.omicron.at>
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
Received: from mga09.intel.com ([134.134.136.24]:27255 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753418Ab2HWQjd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 12:39:33 -0400
In-Reply-To: <20120823112426.GD2238@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Richard Cochran
> Sent: Thursday, August 23, 2012 4:24 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Vick, Matthew; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 12/13] igb: Correct PTP support query from
> ethtool.
> 
> On Thu, Aug 23, 2012 at 02:56:52AM -0700, Jeff Kirsher wrote:
> > From: Matthew Vick <matthew.vick@intel.com>
> >
> > Update ethtool_get_ts_info to not report any supported functionality
> > on
> > 82575 and add support for V2 Sync and V2 Delay packets. In the case
> > where CONFIG_IGB_PTP is not defined, we should be reporting default
> > values.
> 
> > diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> > b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> 
> ...
> 
> > +#endif /* CONFIG_IGB_PTP */
> > +	default:
> > +		return ethtool_op_get_ts_info(dev, info);
> 
> This is wrong. Using this function advertises that you support SW TX
> time stamps, which you do not.
> 
> Thanks,
> Richard

Thanks--good catch! I thought we supported SW timestamps already. Since we don't, I'll spin a v2 of this patch.

Cheers,
Matthew
