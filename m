From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next-2.6 RFC PATCH] ethtool: allow custom interval for
 physical identification
Date: Tue, 12 Apr 2011 19:23:19 +0100
Message-ID: <1302632599.2880.26.camel@bwh-desktop>
References: <20110411231635.9339.36369.stgit@gitlad.jf.intel.com>
	 <20110411162601.6686f169@nehalam>
	 <8DD2590731AB5D4C9DBF71A877482A90018A2A30A9@orsmsx509.amr.corp.intel.com>
	 <1302566453.5282.585.camel@localhost>
	 <8DD2590731AB5D4C9DBF71A877482A90018A2A315B@orsmsx509.amr.corp.intel.com>
	 <1302625686.2880.24.camel@bwh-desktop>
	 <8DD2590731AB5D4C9DBF71A877482A90018A2A3559@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:43070 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757743Ab1DLSXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 14:23:22 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A90018A2A3559@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-12 at 11:17 -0700, Allan, Bruce W wrote:
> >-----Original Message-----
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >Sent: Tuesday, April 12, 2011 9:28 AM
> >To: Allan, Bruce W
> >Cc: Stephen Hemminger; netdev@vger.kernel.org
> >Subject: RE: [net-next-2.6 RFC PATCH] ethtool: allow custom interval for
> >physical identification
> >
> >I enquired here and found that we do have an OEM specifying 1 Hz.
> >
> >> FWIW, without digging too deep into how other drivers identify their
> >> respective ports through software, it appears it was split:
> >> * bnx2*, cxgb3, niu, s2io, sfc, sky2, tg3 - once per second
> >> * e100*, igb, ixgb*, pcnet32, ewrk3, cxgb4 - approx. twice per second
> >>
> >> AFAIK for parts that can set the physical identification through hardware,
> >> the Intel drivers set the on/off intervals to approximately twice/second;
> >> I don't know what other drivers do in that situation.
> >>
> >> So, I would guess it is not a common requirement to blink at a specific Hz.
> >> I have no problem with changing the hard-coded blink frequency to what our
> >> OEMs expect, but that might be an issue for those other vendors; I was just
> >> trying to make it flexible.
> >
> >Sadly it appears this is necessary.
> >
> >Let's define the return value for drivers wanting periodic callbacks to
> >be the blink frequency in Hz (normally 1 or 2), and get rid of the
> >special case of -EINVAL.  This also removes the rather inelegant
> >semantic that drivers may need to change their state despite returning
> >an error code.
> >
> >Ben.
> 
> OK.  Would you like me to send an updated patch?

Please.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

