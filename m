From: chunkeey@web.de
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Fri, 17 Nov 2006 21:53:50 +0100
Message-ID: <200611172153.50278.chunkeey@web.de>
References: <200610031457.33215.chunkeey@web.de> <200611172043.27588.chunkeey@web.de> <d120d5000611171216y76098a6bv86cba96160fee0eb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:13956 "EHLO
	fmmailgate02.web.de") by vger.kernel.org with ESMTP
	id S1753089AbWKQUxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 15:53:53 -0500
To: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
In-Reply-To: <d120d5000611171216y76098a6bv86cba96160fee0eb@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> The card is WG511 talking to netgear WGR614 router. I am using WEP128
> with shared keys. Router is set to be "g" only. The OS is Fedora Core
> 3 (I swear I will upgrade :) ), just recompiled wireless tools from
> sources in FC6.
>
> > for debugging:
> > dmesg & iwevent output would be nice...
>
> Will do when I get home.
>
> > but I'll accept a short "sniffer" extract too. ;)
> >
> > (it would be really good, if you can provide a package dump form a
> > working setup with the old driver too!)
>
> You'd have to tell me exactly what you want me to do.
just the Management Frames (MLME):
Beacon, Authentication and Association Responses/Requests Frames
you can capture these frames with an extra sniffer card (in monitor mode)
just run tcpdump, wireshark(ethereal), kismet, ...


>
> The reason for me trying the patch is that the card locks up
> frequently (the amber transmission light turns on stays this way).
 
Do you get any fancy "mgt timeout ..." or something in dmesg, when
the cards locks up? (include one, if you can, maybe syslog "saved" one)
