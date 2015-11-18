From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Hardware capabilities and bonding offload
Date: Wed, 18 Nov 2015 15:50:38 +0100
Message-ID: <20151118145038.GC3232@lunn.ch>
References: <77EF4405DD4BB54AACCE7DB593DF6A9AA0D643@SJEXCHMB14.corp.ad.broadcom.com>
 <20151116153032.GC2217@nanopsycho.orion>
 <5649FFF3.9080401@gmail.com>
 <20151117220349.GA7762@penelope.isobedori.kobe.vergenet.net>
 <564BCD12.4010804@gmail.com>
 <20151118140512.GC6123@lunn.ch>
 <20151118142923.GA2192@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Simon Horman <simon.horman@netronome.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36472 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933394AbbKROun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 09:50:43 -0500
Content-Disposition: inline
In-Reply-To: <20151118142923.GA2192@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015 at 03:29:23PM +0100, Jiri Pirko wrote:
> Wed, Nov 18, 2015 at 03:05:12PM CET, andrew@lunn.ch wrote:
> >> To be honest though this is more of an argument in theory versus
> >> some existing management agent I know of today. If you need to do
> >> bonding type X in your network and the particular switch doesn't support
> >> it I'm not even sure what the mgmt layer is going to do. Maybe just
> >> put the switch offline for that network segment.
> >> 
> >> If you leave the sw bit out in the first iteration I'm OK with that
> >> we can easily add it when we have software that needs it.
> >
> >Taking a step back...
> >
> >Have we defined a consistent way for signalling:
> >
> >1) Failed to offload to the hardware, because the hardware cannot do
> >   what you requested.
> >2) Do this in software, rather than trying and failing to offload to
> >   hardware.
> >
> >At least in DSA, we return EOPNOTSUP for 1).
> 
> Well for example in case of bonding there is quite impossible to do
> things in software in case the hardware datapath simply cannot pass
> packets to kernel. Driver should know and should forbid such
> non-functional setup.

I said, "taking a step back..." meaning, in the general case, do we
have a well defined way to do this. What we don't want is X different
ways for Y difference API calls to say, if offload of this to hardware
fails, do it in software, if that is possible.

       Andrew
