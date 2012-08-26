From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Sun, 26 Aug 2012 15:01:29 +0200
Message-ID: <20120826130129.GA4729@netboy.at.omicron.at>
References: <20120823110357.GB2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD039@ORSMSX101.amr.corp.intel.com>
 <20120823172950.GA2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EFE@ORSMSX105.amr.corp.intel.com>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD35B@ORSMSX101.amr.corp.intel.com>
 <20120824101053.GA6038@netboy.at.omicron.at>
 <1345827088.2694.11.camel@bwh-desktop.uk.solarflarecom.com>
 <02874ECE860811409154E81DA85FBB5807858A31@ORSMSX105.amr.corp.intel.com>
 <20120825062013.GB2233@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB58078591DF@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59857 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942Ab2HZNBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Aug 2012 09:01:42 -0400
Received: by weyx8 with SMTP id x8so1878222wey.19
        for <netdev@vger.kernel.org>; Sun, 26 Aug 2012 06:01:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB58078591DF@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 26, 2012 at 01:33:42AM +0000, Keller, Jacob E wrote:
> 
> IMO it should be but only for parts with HWTSTAMP_FILTER_ALL, and only for that mode (other modes should be ignored) because timestamping only PTP packets is a PTP feature, so this change should still disable other modes if they exist.

Yes, the other Rx modes are PTP specific, and they don't make sense
unless the PTP clock is also enabled.

IIRC, on the Tx side, the 82580 can time stamp any marked packet
regardless of the packet contents, so this should also be always
available, along with HWTSTAMP_FILTER_ALL.

Thanks,
Richard
