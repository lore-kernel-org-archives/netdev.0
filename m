From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [RFC, 1/2] ethtool:  Implement private flags interface for
 ethtool application.
Date: Fri, 02 Sep 2011 22:36:39 +0100
Message-ID: <1314999399.3419.21.camel@bwh-desktop>
References: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
	 <1314998831.3419.12.camel@bwh-desktop>
	 <EDC0E76513226749BFBC9C3FB031318F0173FF8650@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:29811 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024Ab1IBVgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 17:36:42 -0400
In-Reply-To: <EDC0E76513226749BFBC9C3FB031318F0173FF8650@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-02 at 14:33 -0700, Wyborny, Carolyn wrote:
> 
> >-----Original Message-----
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >Sent: Friday, September 02, 2011 2:27 PM
> >To: Wyborny, Carolyn
> >Cc: davem@davemloft.net; netdev@vger.kernel.org
> >Subject: Re: [RFC, 1/2] ethtool: Implement private flags interface for
> >ethtool application.
> >
> >On Fri, 2011-09-02 at 13:50 -0700, Carolyn Wyborny wrote:
> >> This patch completes the user space implementation of the private
> >> flags inteface in ethtool. Using -b/-B options.
> >[...]
> >
> >Private flags are supposed to be named (string set ETH_SS_PRIV_FLAGS).
> >ethtool should only support getting and setting flags by name, not
> >number.  That way people can actually remember what the flags do and
> >their scripts won't break when the driver changes flag numbers.
> >
> >Ben.
> >
> >--
> >Ben Hutchings, Staff Engineer, Solarflare
> >Not speaking for my employer; that's the marketing department's job.
> >They asked us to note that Solarflare product names are trademarked.
> 
> Ok, makes sense.  Do you want a private flags implementation or do you
> agree with Michal on extending ETHTOOL_[GS]FEATURES?

I'm happy to add support for private flags identified by name.

(And I still haven't worked out with Michal how we're going to handle
the new features interface in ethtool. :-/)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
