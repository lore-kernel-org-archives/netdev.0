From: Werner Almesberger <wa@almesberger.net>
Subject: Re: WLAN power saving: brain dump
Date: Sun, 21 Nov 2004 21:44:21 -0300
Message-ID: <20041121214421.B29528@almesberger.net>
References: <20041116113027.A4026@almesberger.net> <20041121192225.GF4009@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
In-Reply-To: <20041121192225.GF4009@obroa-skai.de.gnumonks.org>; from laforge@gnumonks.org on Sun, Nov 21, 2004 at 08:22:25PM +0100
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald Welte wrote:
> Mh.  Don't recent 802.11 chipsets already have a number of power-saving
> features, even going as far as having special provisions in the 802.11
> protocol for special power saving modes?

They do, but they're still very power-hungry. (Well above 100 mW,
it seems.)

But meanwhile I've been pointed to new technology that should do
a lot better in this regard:
http://www.semiconductors.philips.com/technologies/wirelessconnectivity/80211b/

So maybe active power management from the host would only be
needed for obsolete hardware in the not too distant future.
Still, there's a lot of this around ...

> Sorry for that indefinitive and blurry response, but power saving is the
> about the single part of 802.11 that I'm actually not really interested
> in (and thus haven't read up with the docs).

With a PDA, it's be about the only thing you think about ;-)

> The problem when you just 'stupidly' power down a card is that you will
> loose the association [and thus authentication] with the AP.

Yes, that's what worries me a bit. A few hundred ms of delay
should be fine, but if it takes longer, that might be a problem.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
