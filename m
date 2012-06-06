From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next PATCH v2 1/3] Added kernel support in EEE Ethtool
 commands
Date: Wed, 6 Jun 2012 18:41:51 +0100
Message-ID: <1339004511.2836.43.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338973098-16439-1-git-send-email-yuvalmin@broadcom.com>
	 <1338973098-16439-2-git-send-email-yuvalmin@broadcom.com>
	 <1338996011.2836.2.camel@bwh-desktop.uk.solarflarecom.com>
	 <979A8436335E3744ADCD3A9F2A2B68A50268AA@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43096 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755181Ab2FFRly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 13:41:54 -0400
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A50268AA@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 16:40 +0000, Yuval Mintz wrote:
> > > + * @supported: Link speeds for which there is eee support.
> > > + * @advertised: Link speeds the interface advertises (AN) as eee capable.
> > > + * @lp_advertised: Link speeds the link partner advertised as eee capable.
> > 
> > And these are bitmasks of SUPPORTED_* & ADVERTISED_* flags, right?
> 
> Right.
> 
> > Maybe 'link modes' not 'link speeds'?
> 
> Not that it matters greatly, but there are SUPPORTED & ADVERTISED flags for
> things other than link speeds, such as connection type and flow control,
> so using exactly the same semantic in description might confuse someone.

What I'm getting at is that we don't have flags for speeds; we have
flags for modes (speed/duplex combination).  I think EEE only works with
full-duplex modes but clients and drivers will still have to specify
that explicitly in flag names.

I can see that 'link modes' might be slightly ambiguous, so how about:

        @supported: Mask of %SUPPORTED_* flags for the speed/duplex
        combinations for which there is EEE support.

and similarly for the other fields.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
