From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Mon, 10 Sep 2012 22:58:35 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD34488E717B@ORSMSX101.amr.corp.intel.com>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120906081315.GF2550@netboy.at.omicron.at>
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
Received: from mga01.intel.com ([192.55.52.88]:56485 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753766Ab2IJW6h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 18:58:37 -0400
In-Reply-To: <20120906081315.GF2550@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Richard Cochran
> Sent: Thursday, September 06, 2012 1:13 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com
> Subject: Re: [net-next 0/6][pull request] Intel Wired LAN Driver
> Updates
> 
> On Wed, Sep 05, 2012 at 04:35:00PM -0700, Jeff Kirsher wrote:
> >
> > Matthew Vick (6):
> >   igb: Tidy up wrapping for CONFIG_IGB_PTP.
> >   igb: Update PTP function names/variables and locations.
> >   igb: Correct PTP support query from ethtool.
> >   igb: Store the MAC address in the name in the PTP struct.
> 
> These four still look like unnecessary churn to me, and possibly the
> wrong direction WRT time stamping in the 82580.

(I apologize for the delayed response--I was out of the office. I've read through the discussions and will respond here in the interest of brevity.)

I still fail to see how they're churn. I'm making the code make sense for what is actually supported today. I understand that, theoretically, some of this work may be reverted if/when we pull out hardware timestamping as a separate feature from the PTP support in the driver, but I don't think we should leave it general because someone someday might get around to doing something with it. It's confusing and more difficult to maintain for no benefit. It should be part of the development effort to generalize and consolidate where possible when adding a feature.

> >   igb: Prevent dropped Tx timestamps via work items and interrupts.
> >   igb: Add 1588 support to I210/I211.
> 
> But these two look important, so I don't know what to say.
> 
> Sorry,
> Richard

Those two are definitely important. :)

Cheers,
Matthew
