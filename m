From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 4/6] igb: Store the MAC address in the name in the
 PTP struct.
Date: Thu, 6 Sep 2012 22:59:36 +0000
Message-ID: <02874ECE860811409154E81DA85FBB580785F9F4@ORSMSX105.amr.corp.intel.com>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1346888106-25638-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120906080628.GD2550@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40543 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173Ab2IFW7j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 18:59:39 -0400
In-Reply-To: <20120906080628.GD2550@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Richard Cochran
> Sent: Thursday, September 06, 2012 1:06 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Vick, Matthew; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 4/6] igb: Store the MAC address in the name in the
> PTP struct.
> 
> On Wed, Sep 05, 2012 at 04:35:04PM -0700, Jeff Kirsher wrote:
> > From: Matthew Vick <matthew.vick@intel.com>
> >
> > Change the name of the adapter in the PTP struct to enable easier
> > correlation between interface and PTP device.
> 
> Still think it is better to have the driver name, not the MAC address.
> The correlation is clear by using the ethtool method.
> 

I found a method to correct the init code so that the device name can appear here, and I would prefer that over either the driver name or MAC address. It requires moving the ptp initialization into the netdev open handler though.

- Jake

> Thanks,
> Richard
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
