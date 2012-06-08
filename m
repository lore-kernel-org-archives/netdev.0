From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1 v2] Ethtool: Add EEE support
Date: Fri, 8 Jun 2012 19:14:26 +0100
Message-ID: <1339179266.2648.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339010124-23413-1-git-send-email-yuvalmin@broadcom.com>
	 <1339179089.2648.5.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eilong@broadcom.com>,
	<peppe.cavallaro@st.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56063 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932400Ab2FHSO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 14:14:29 -0400
In-Reply-To: <1339179089.2648.5.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-08 at 19:11 +0100, Ben Hutchings wrote:
> On Wed, 2012-06-06 at 22:15 +0300, Yuval Mintz wrote:
> > This patch adds 2 new ethtool commands which can be
> > used to manipulate network interfaces' support in
> > EEE.
> [...]
> > @@ -3423,6 +3514,12 @@ static const struct option {
> >  	  "		[ hex on|off ]\n"
> >  	  "		[ offset N ]\n"
> >  	  "		[ length N ]\n" },
> > +	{ "--get-eee", 1, do_geee, "Get EEE settings"},
> > +	{ "--set-eee", 1, do_seee, "Set EEE settings",
> > +	  "		[ eee on|off ]\n"
> > +	  "		[ advertise %x ]\n"
> > +	  "		[ tx-lpi on|off ]\n"
> > +	  "		[ tx-timer %d ]\n"},
> [...]
> 
> Another thing: the long options are generally --foo to set/change foo
> settings and --show-foo to get/show foo settings.  Please rename these
> options to match.

Hmm, we already have a lot of --set-foo options, so never mind that.
But do change --get-eee to --show-eee.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
