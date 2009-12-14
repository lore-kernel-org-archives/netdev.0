From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: RFC: ethtool: add device-specific feature support in a generic
 fashion
Date: Sun, 13 Dec 2009 22:12:00 -0800
Message-ID: <1260771120.20884.17.camel@localhost>
References: <1260671599.2142.79.camel@localhost>
	 <4B246B46.1010103@candelatech.com>	<1260688164.2142.84.camel@localhost>
	 <20091213.201957.232755179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "greearb@candelatech.com" <greearb@candelatech.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65402 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752715AbZLNGMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2009 01:12:01 -0500
In-Reply-To: <20091213.201957.232755179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-12-13 at 20:19 -0800, David Miller wrote:
> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Date: Sat, 12 Dec 2009 23:09:24 -0800
> 
> > Excellent points.  Thanks Ben!
> 
> See ethtool_gstrings please.
> 

Yes, I looked at this before, then started thinking about it harder than
I needed to.

> There is no reason to put a "char *" in any of your interfaces, just
> as we don't need to in the existing ethtool stats stuff.
> 

Ah, right.  Just a pointer to a chunk of data.  I see now.

> And you can put the number of knobs available in struct
> ethtool_drvinfo right before n_priv_flags where we have a reserved
> area just for adding things like this.
> 
> You are specifying way too much new stuff in your datastructures,
> unnecessary duplicating existing structures and facilities.

Yeah, I was making this too complicated.  Glad I sent the RFC on the
design first before writing any code.  :-)

> I pointed you at the ethtool private stats stuff because you
> can reuse %85 of it's implementation for your purposes :-)

Right!  In this case, I just needed a firmer bonk on the head to look in
the right direction.

On the right track now Dave, thanks.

-PJ

