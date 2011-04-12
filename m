From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next-2.6 RFC PATCH] ethtool: allow custom interval for
 physical identification
Date: Tue, 12 Apr 2011 01:00:53 +0100
Message-ID: <1302566453.5282.585.camel@localhost>
References: <20110411231635.9339.36369.stgit@gitlad.jf.intel.com>
	 <20110411162601.6686f169@nehalam>
	 <8DD2590731AB5D4C9DBF71A877482A90018A2A30A9@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18997 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab1DLAA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 20:00:58 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A90018A2A30A9@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-11 at 16:30 -0700, Allan, Bruce W wrote:
> >-----Original Message-----
> >From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> >Sent: Monday, April 11, 2011 4:26 PM
> >To: Allan, Bruce W
> >Cc: netdev@vger.kernel.org
> >Subject: Re: [net-next-2.6 RFC PATCH] ethtool: allow custom interval for
> >physical identification
> >
> >On Mon, 11 Apr 2011 16:16:35 -0700
> >Bruce Allan <bruce.w.allan@intel.com> wrote:
> >
> >> When physical identification of an adapter is done by toggling the
> >> mechanism on and off through software utilizing the .set_phys_id operation,
> >> it is done with a fixed duration for both on and off states.  Some drivers
> >> may want to set a custom duration for the on/off intervals.  This patch
> >> changes the API so the return code from the driver's entry point can
> >> specify the interval duration as a positive number; -EINVAL is still
> >> allowed in order to use the default single on/off interval per second.
> >>
> >> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> >
> >IMHO this is -EOVERKILL.
> 
> I realize it does seem like that, but we have OEMs that expect the LEDs to
> blink a certain way during a physical identification (twice a second vs.
> once a second per the original .set_phys_id patchset).  There may be other
> drivers from different hardware vendors that have similar but different
> requirements.

I noticed that some drivers did this.  Do you know if these OEMs expect
this of all hardware, or do they actually want different vendors'
hardware to blink in different ways?  If it's a common requirement to
blink at 2 Hz then let's use that frequency for all the drivers that
want to be called periodically.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

