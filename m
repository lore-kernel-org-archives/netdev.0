From: Jouni Malinen <j@w1.fi>
Subject: Re: [PATCH] PS3: gelic: Add wireless support for PS3
Date: Sun, 16 Dec 2007 10:11:59 -0800
Message-ID: <20071216181159.GP5698@jm.kir.nu>
References: <20071213211626.BF8E.MOKUNO@sm.sony.co.jp> <1197580418.14270.6.camel@localhost.localdomain> <20071214134918.275E.MOKUNO@sm.sony.co.jp> <1197637127.16724.1.camel@localhost.localdomain> <20071215014244.GI5698@jm.kir.nu> <1197827354.6358.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masakazu Mokuno <mokuno@sm.sony.co.jp>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	geoffrey.levand@am.sony.com,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:50583 "EHLO
	mail3.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbXLPSNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 13:13:08 -0500
Content-Disposition: inline
In-Reply-To: <1197827354.6358.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 16, 2007 at 12:49:14PM -0500, Dan Williams wrote:

> Yeah, I was going to propose that on Friday but got side-tracked.  What
> would require a new key type?  Are there some firmwares that _only_
> accept the WPA passphrase?  Because if there aren't (PS3 accepts WPA hex
> keys too) then the supplicant could just pass the hex key.  Not quite
> sure what you mean here with "new key type".

It is a new key type regardless of whether it is PSK or passphrase. The
current key types (IW_AUTH_CIPHER_*) are WEP40, TKIP, CCMP, and WEP104..

I don't know whether there are any Linux drivers that would use WPA
passphrase, but at least the Mac OS X driver interface seems to only use
passphrase for WPA-Personal, so it is apparently possible to design such
a architecture ;-). Anyway, I would be fine with just adding
IW_AUTH_CIPHER_PMK for now (and the new capability to figure out whether
this is needed). That PMK would be PSK for WPA-Personal, but it could
also be used as PMK for WPA-Enterprise, so the more generic PMK name.

-- 
Jouni Malinen                                            PGP id EFC895FA
