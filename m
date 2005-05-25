From: Pavel Machek <pavel@suse.cz>
Subject: Re: [0/5] Improvements to the ieee80211 layer
Date: Wed, 25 May 2005 11:27:10 +0200
Message-ID: <20050525092710.GA1926@elf.ucw.cz>
References: <20050524150711.01632672@griffin.suse.cz> <20050524185241.GB2470@elf.ucw.cz> <20050525082956.GA20739@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jirka Bohac <jbohac@suse.cz>
Content-Disposition: inline
In-Reply-To: <20050525082956.GA20739@dwarf.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

> > > This is the first series of patches that try to convert it to a generic
> > > IEEE 802.11 layer, usable for most of today's wireless cards.
> > 
> > Are they against -rc4-mm2?
> 
> No, they're against -rc3-mm3. The whole ieee80211 layer has been
> accidentally removed from -rc4-mm3 (see
> http://lkml.org/lkml/2005/5/18/57 )
> 
> > Would it be possible to put agregate patch on the web somewhere (or
> > git tree?). I would certainly be easier to test....
> 
> Hmm, always thought that small patches would be preferred ;-)
> Here you go: http://jikos.cz/~jbohac/tmp/big_80211_patch_01.patch.bz2
> This is combined from all the 11 patches we posted yesterday

Well, they certainly are prefered for review, but applying series of
11 patches, with two that need to be get from the web is not that
easy....

I could not compile it:

  CC      net/ieee80211/ieee80211_rx.o
net/ieee80211/ieee80211_rx.c: In function
`ieee80211_rx_frame_decrypt':
net/ieee80211/ieee80211_rx.c:281: error: `dev' undeclared (first use
in this function)
net/ieee80211/ieee80211_rx.c:281: error: (Each undeclared identifier
is reported only once
net/ieee80211/ieee80211_rx.c:281: error: for each function it appears
in.)
make[2]: *** [net/ieee80211/ieee80211_rx.o] Error 1
make[1]: *** [net/ieee80211] Error 2
make: *** [net] Error 2
468.99user 31.35system 523.98 (8m43.981s) elapsed 95.49%CPU
pavel@amd:/data/l/linux-mm$

After fixing that, ipw2100 seems to work. [Funny, it changed name from
eth1 to wlan0?] Good.

								Pavel
