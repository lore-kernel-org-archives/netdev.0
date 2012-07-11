From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 09/10] ixgbe: Add support for displaying the number
 of Tx/Rx channels
Date: Wed, 11 Jul 2012 19:21:43 +0100
Message-ID: <1342030903.2613.52.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
	 <20120630001659.29939.61276.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <edumazet@google.com>,
	<therbert@google.com>, <alexander.duyck@gmail.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15677 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756631Ab2GKSVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 14:21:47 -0400
In-Reply-To: <20120630001659.29939.61276.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-29 at 17:16 -0700, Alexander Duyck wrote:
> This patch adds support for the ethtool get_channels operation.
> 
> Since the ixgbe driver has to support DCB as well as the other modes the
> assumption I made here is that the number of channels in DCB modes refers
> to the number of queues per traffic class, not the number of queues total.
[...]

When MSI-X is enabled, a 'channel' is an MSI-X vector and the associated
queues, i.e. total number of channels reported should be the total
number of MSI-X vectors in use.  (That was my intended interpretation,
anyway.  It may be that there is too much variation in the way queues
and interrupts are associated for these operations to be defined in a
general way.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
