From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 11/16] net: dsa: Refactor selection of tag ops into a
 function
Date: Fri, 27 May 2016 22:11:43 +0200
Message-ID: <20160527201143.GB23212@lunn.ch>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
 <1464312050-23023-12-git-send-email-andrew@lunn.ch>
 <878tyvz42q.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53102 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756525AbcE0ULp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2016 16:11:45 -0400
Content-Disposition: inline
In-Reply-To: <878tyvz42q.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2016 at 03:35:57PM -0400, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > @@ -26,6 +26,7 @@ enum dsa_tag_protocol {
> >  	DSA_TAG_PROTO_TRAILER,
> >  	DSA_TAG_PROTO_EDSA,
> >  	DSA_TAG_PROTO_BRCM,
> > +	_DSA_TAG_LAST,
> >  };
> 
> I would avoid _ prefixed functions or symbols, we've seen in mv88e6xxx
> that it doesn't make the code really readable.

The point is to make is special, so that people look at it, wonder why
it is special, and don't make the stupid mistakes of adding a new
protocol after it.

However, if you don't like the _, we can just add a comment
/* MUST BE LAST */

> I don't see the need to add a dsa_device_ops array. I'd keep the switch
> case on tag_protocol within this new dsa_resolve_tag_protocol function,
> to make it more readable (no value checking necessary).

I don't see one way being better than the other. I see it as a
personal preference. If you don't like it, i won't NACK a patch
submitted after it has been accepted which changes it to your personal
preference.

      Andrew
