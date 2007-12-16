From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] PS3: gelic: Add wireless support for PS3
Date: Sun, 16 Dec 2007 18:10:10 -0500
Message-ID: <1197846610.7302.1.camel@localhost.localdomain>
References: <20071213211626.BF8E.MOKUNO@sm.sony.co.jp>
	 <1197580418.14270.6.camel@localhost.localdomain>
	 <20071214134918.275E.MOKUNO@sm.sony.co.jp>
	 <1197637127.16724.1.camel@localhost.localdomain>
	 <20071215014244.GI5698@jm.kir.nu>
	 <1197827354.6358.2.camel@localhost.localdomain>
	 <20071216181159.GP5698@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>
To: Jouni Malinen <j@w1.fi>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071216181159.GP5698-mgr6C1c9aYeHXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-12-16 at 10:11 -0800, Jouni Malinen wrote:
> On Sun, Dec 16, 2007 at 12:49:14PM -0500, Dan Williams wrote:
> 
> > Yeah, I was going to propose that on Friday but got side-tracked.  What
> > would require a new key type?  Are there some firmwares that _only_
> > accept the WPA passphrase?  Because if there aren't (PS3 accepts WPA hex
> > keys too) then the supplicant could just pass the hex key.  Not quite
> > sure what you mean here with "new key type".
> 
> It is a new key type regardless of whether it is PSK or passphrase. The
> current key types (IW_AUTH_CIPHER_*) are WEP40, TKIP, CCMP, and WEP104..

Ah, it's a different key because it's not set _during_ the 4-way
handshake, but just sent to the fw directly and the fw handles it,
right?

> I don't know whether there are any Linux drivers that would use WPA
> passphrase, but at least the Mac OS X driver interface seems to only use
> passphrase for WPA-Personal, so it is apparently possible to design such
> a architecture ;-). Anyway, I would be fine with just adding
> IW_AUTH_CIPHER_PMK for now (and the new capability to figure out whether
> this is needed). That PMK would be PSK for WPA-Personal, but it could
> also be used as PMK for WPA-Enterprise, so the more generic PMK name.

Sounds good.

Dan
