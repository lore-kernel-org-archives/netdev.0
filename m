From: chunkeey@web.de
Subject: Re: [PATCH] prism54: wpa support for fullmac cards
Date: Thu, 5 Oct 2006 19:17:44 +0200
Message-ID: <200610051917.44560.chunkeey@web.de>
References: <200610031457.33215.chunkeey@web.de> <200610041612.26824.chunkeey@web.de> <20061004214341.GP10337@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: chunkeey@web.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:35973 "EHLO
	fmmailgate02.web.de") by vger.kernel.org with ESMTP
	id S1751403AbWJERSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 13:18:11 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20061004214341.GP10337@instant802.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 04, 2006 23:43 you wrote:
> On Wed, Oct 04, 2006 at 04:12:26PM +0200, chunkeey@web.de wrote:
> > the AP code never worked. And the hostapd-ioctl interface was designed
> > for prism2/2.5/3 cards, but not for "fullmac" prism54.
>
> What do you mean by never working? I have seen fullmac Prism54
> completing WPA authentication with hostapd.. This was using the
> driver_prism54.c in hostapd, not the Host AP driver interface.
> > (BTW, hostapd's backend for prism54 uses a "proprietary" interface -
> > PIMFOR -, which never made it into the kernel.)
>
> But it worked in the external driver. So yes, saying that the version in
> kernel tree never worked in AP mode would probably be valid.
>
ok, sorry my fault, I should have put it this was:

it was never woking for ME, linmax, roland warsow, ...
and I tried alot of things. (patches, how-tos, ask the maintainer, etc. )
But i only saw "Oops" or "mgt: queue full" ...
 
the PIMFOR-Interface is a direct "tunnel" to the hardware.
And guess what? it's very "crashy" .. (e.g "set/get the generic elements" does 
a very good job. ;) )

> And as far as the WEXT interface in hostapd is concerned, no, there is
> no such thing yet.

that's correct.
WEXT is not going anywhere anymore, but maybe cfg80211?

Chr
 
