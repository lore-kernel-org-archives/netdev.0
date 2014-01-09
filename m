From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] ethtool: Accept long feature names reported by
 -k option as input to -K option
Date: Thu, 9 Jan 2014 21:11:32 +0000
Message-ID: <1389301892.2025.45.camel@bwh-desktop.uk.level5networks.com>
References: <1389217931.1644.44.camel@bwh-desktop.uk.level5networks.com>
	 <804857E1F29AAC47BF68C404FC60A18465428D1D@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Bill Fink <billfink@mindspring.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26671 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754343AbaAIVLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 16:11:36 -0500
In-Reply-To: <804857E1F29AAC47BF68C404FC60A18465428D1D@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-08 at 22:00 +0000, Allan, Bruce W wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Ben Hutchings
> > Sent: Wednesday, January 08, 2014 1:52 PM
> > To: Or Gerlitz; Bill Fink; netdev@vger.kernel.org
> > Subject: [PATCH ethtool] ethtool: Accept long feature names reported by -k
> > option as input to -K option
> > 
> > Before the generic features API was introduced, the ethtool -K option
> > took short names for various features, e.g. 'gso' but the -k option
> > reported their state using longer names,
> > e.g. 'generic-segmentation-offload'.
> > 
> > All newer features have a single kernel-provided name so input
> > and output are consistent.  But the old features still aren't, and
> > although their short names are documented it's not good to have
> > these exceptions.
> > 
> > Change the argument parsing code for -K so that the long names
> > reported by -k are also accepted.
> > 
> > Reported-by: Or Gerlitz <or.gerlitz@gmail.com>
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > This turned out to be pretty easy to do as the argument processing is
> > all table-driven already.  I'll push this if it works for you.
> > 
> > Ben.
> > 
> >  ethtool.c | 16 +++++++++++-----
> >  1 file changed, 11 insertions(+), 5 deletions(-)
> 
> Will there be an update to the man page, too?

I wasn't intending to do so.  The set of feature names is not known at
compile time so I think it should only list the names that *aren't*
reported by ethtool -K (the short names).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
