From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next 08/11] e1000e: add Receive Packet Steering (RPS)
 support
Date: Fri, 6 Jan 2012 17:31:11 +0000
Message-ID: <1325871071.2850.13.camel@bwh-desktop>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1325624728.2832.12.camel@bwh-desktop>
	 <804857E1F29AAC47BF68C404FC60A18403B8ED@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7626 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752842Ab2AFRbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 12:31:16 -0500
In-Reply-To: <804857E1F29AAC47BF68C404FC60A18403B8ED@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-06 at 17:22 +0000, Allan, Bruce W wrote:
> >-----Original Message-----
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >Sent: Tuesday, January 03, 2012 1:05 PM
> >To: Kirsher, Jeffrey T
> >Cc: davem@davemloft.net; Allan, Bruce W; netdev@vger.kernel.org;
> >gospo@redhat.com; sassmann@redhat.com
> >Subject: Re: [net-next 08/11] e1000e: add Receive Packet Steering (RPS) support
> >
> >On Tue, 2012-01-03 at 11:19 -0800, Jeff Kirsher wrote:
> >> From: Bruce Allan <bruce.w.allan@intel.com>
> >>
> >> Enable RPS by default.  Disallow jumbo frames when both receive checksum
> >> and receive hashing are enabled because the hardware cannot do both IP
> >> payload checksum (enabled when receive checksum is enabled when using
> >> packet split which is used for jumbo frames) and provide RSS hash at the
> >> same time.
> >[...]
> >
> >This doesn't seem to have much to do with RPS.  RPS can use a hardware
> >hash but doesn't require it.
> >
> >You should also implement the ethtool command to query flow hashing
> >behaviour (ETHTOOL_GRXFH command, get_rxnfc operation).
> >
> >Ben.
> >
> >--
> >Ben Hutchings, Staff Engineer, Solarflare
> >Not speaking for my employer; that's the marketing department's job.
> >They asked us to note that Solarflare product names are trademarked.
> 
> Thanks for the feedback Ben.  One question: is the data returned from
> an ETHTOOL_GRXFH command with the get_rxnfc operation supposed to be
> the default for the device or the current setting?

It's supposed to return the current setting.  There's no way to find out
the default once the behaviour has been changed.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
