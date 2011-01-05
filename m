From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] net: Allow ethtool to set interface in loopback
 mode.
Date: Wed, 05 Jan 2011 01:59:10 +0000
Message-ID: <1294192750.2992.29.camel@localhost>
References: <AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com>
	 <1294187401-4662-1-git-send-email-maheshb@google.com>
	 <20110104163645.0b3a3687@nehalam>	<1294190504.2992.3.camel@localhost>
	 <20110104172939.711b758d@nehalam>  <4D23CAA5.7060902@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Mahesh Bandewar <maheshb@google.com>,
	David Miller <davem@davemloft.net>,
	Laurent Chavey <chavey@google.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51002 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab1AEB7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 20:59:14 -0500
In-Reply-To: <4D23CAA5.7060902@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-04 at 17:34 -0800, Rick Jones wrote:
> >>>Since this is a boolean it SHOULD go into ethtool_flags rather than
> >>>being a high level operation.
> >>
> >>It could do, but I though ETHTOOL_{G,S}FLAGS were intended for
> >>controlling offload features.
> > 
> > 
> > It just seems the number of hooks keeps growing which takes more space
> > and increases complexity.
> 
> Is there any complication/downside to using flags in the (un?)likely event of 
> wanting different flavors of loopback in the card?

You have to define the flags.   And once you start, where would you
stop?  The sfc driver alone recognises 18 host-side and 8 wire-side
loopback modes.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

