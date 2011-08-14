From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH 1/3] drivers/staging/rtl8187se: Don't pass huge struct
 by value
Date: Sun, 14 Aug 2011 20:32:49 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1108142031330.14271@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1108130054220.7387@swampdragon.chaosbits.net> <20110813180531.34a47d9bf4851f8c1e9a227c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Greg Kroah-Hartman <gregkh@suse.de>, devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org,
	Andrea Merello <andreamrl@tiscali.it>,
	Andre Nogueira <andre.neo.net@gmail.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stefan Weil <weil@mail.berlios.de>,
	Ilia Mirkin <imirkin@alum.mit.edu>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:11204 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754617Ab1HNSch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2011 14:32:37 -0400
In-Reply-To: <20110813180531.34a47d9bf4851f8c1e9a227c@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 Aug 2011, Stephen Rothwell wrote:

> Hi all,
> 
> On Sat, 13 Aug 2011 01:04:36 +0200 (CEST) Jesper Juhl <jj@chaosbits.net> wrote:
> >
> > From: Jesper Juhl <jj@chaosbits.net>
> > Date: Sat, 13 Aug 2011 00:51:40 +0200
> > 
> > struct ieee80211_network is fairly large (more than half a kilobyte),
> > so let's pass a pointer instead of passing the entire structure by
> > value when ieee80211_is_54g() and ieee80211_is_shortslot() need to
> > look at a few members.
> > Also remove parentheses around the values being returned from those
> > two functions - 'return' is not a function.
> 
> Also, is there some reason that they are not "static inline bool"
> functions defined directlt in ieee80211.h?
> 
I agree to the bool return type, I should have done that.

the "static inline" and defined in the header bits I didn't do because I 
was afraid that that was not valid in combination with EXPORT_SYMBOL().

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

