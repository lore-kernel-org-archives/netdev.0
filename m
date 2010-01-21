From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/5] ethtool: Introduce n-tuple filter
 programming support
Date: Wed, 20 Jan 2010 18:54:57 -0800 (PST)
Message-ID: <20100120.185457.32730304.davem@davemloft.net>
References: <20100107044905.28605.54076.stgit@localhost.localdomain>
	<1263238353.2781.38.camel@achroite.uk.solarflarecom.com>
	<F86E8680A7D9D74A99DC6345E35A692950109528@orsmsx503.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, deri@ntop.org,
	joseph.gasparakis@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58400
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752904Ab0AUCyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 21:54:47 -0500
In-Reply-To: <F86E8680A7D9D74A99DC6345E35A692950109528@orsmsx503.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Tue, 12 Jan 2010 11:13:54 -0800

>>-----Original Message-----
>>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>>Sent: Monday, January 11, 2010 11:33 AM
>>To: Kirsher, Jeffrey T
>>Cc: davem@davemloft.net; netdev@vger.kernel.org; gospo@redhat.com;
>>Waskiewicz Jr, Peter P; Luca Deri; Gasparakis, Joseph
>>Subject: Re: [net-next-2.6 PATCH 3/5] ethtool: Introduce n-tuple filter
>>programming support
>>
>>It it really necessary to add new driver operations?  It seems to me
>>that it would be preferable to extend {get,set}_rx_nfc() and have the
>>ethtool common code convert between the ethtool_rxnfc and
>>ethtool_rx_ntuple structures.  Does that seem possible?
>>
>
> It is possible, but I'm not sure if it's the right way to go.  The
> nfc routines are just flipping the various engines on in niu, where
> the ntuple routines are for passing full amounts of data through for
> different filters.  Also, I think keeping them separate makes niu
> programming cleaner, which can support both the nfc and ntuple
> modes.

Agreed.
