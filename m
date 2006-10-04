From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH] prism54: wpa support for fullmac cards
Date: Wed, 4 Oct 2006 14:43:41 -0700
Message-ID: <20061004214341.GP10337@instant802.com>
References: <200610031457.33215.chunkeey@web.de> <20061004123849.060a1842@griffin.suse.cz> <1159962011.2708.19.camel@localhost.localdomain> <200610041612.26824.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-10.dex002.intermedia.net ([64.78.21.75]:57649 "EHLO
	dhost002-10.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751167AbWJDVnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 17:43:49 -0400
To: chunkeey@web.de
Content-Disposition: inline
In-Reply-To: <200610041612.26824.chunkeey@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 04, 2006 at 04:12:26PM +0200, chunkeey@web.de wrote:

> the AP code never worked. And the hostapd-ioctl interface was designed 
> for prism2/2.5/3 cards, but not for "fullmac" prism54.

What do you mean by never working? I have seen fullmac Prism54
completing WPA authentication with hostapd.. This was using the
driver_prism54.c in hostapd, not the Host AP driver interface.

> (BTW, hostapd's backend for prism54 uses a "proprietary" interface - 
> PIMFOR -, which never made it into the kernel.) 

But it worked in the external driver. So yes, saying that the version in
kernel tree never worked in AP mode would probably be valid.

And as far as the WEXT interface in hostapd is concerned, no, there is
no such thing yet.

-- 
Jouni Malinen                                            PGP id EFC895FA
