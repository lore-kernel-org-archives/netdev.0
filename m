From: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Fri, 17 Nov 2006 15:16:06 -0500
Message-ID: <d120d5000611171216y76098a6bv86cba96160fee0eb@mail.gmail.com>
References: <200610031457.33215.chunkeey@web.de>
	 <1163169740.2662.6.camel@localhost.localdomain>
	 <200611170042.55404.dtor@insightbb.com>
	 <200611172043.27588.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.239]:25256 "EHLO
	hu-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1755853AbWKQUQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 15:16:09 -0500
Received: by hu-out-0506.google.com with SMTP id 36so449682hui
        for <netdev@vger.kernel.org>; Fri, 17 Nov 2006 12:16:08 -0800 (PST)
To: "chunkeey@web.de" <chunkeey@web.de>
In-Reply-To: <200611172043.27588.chunkeey@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/17/06, chunkeey@web.de <chunkeey@web.de> wrote:
> Am Freitag, 17. November 2006 06:42 schrieben Sie:
> > >
> > > No, more that my card doesn't successfully associate at all even
> > > _without_ the patch on unencrypted or WEP APs; I just can't test it,
> > > since my card seems to be broken...
> >
> > FWIW I applied the patch to tonight pull form Linus's tree and my card
> > stopped associating with my AP (WEP128, Shared key). It only associated
> > with my neighbour router which is running without encryption.
> can you please describe your setup? I tested WEP ("restricted") with a Netgear
> WGT624 and a normal linux AP and haven't seen any problems so far.
>

The card is WG511 talking to netgear WGR614 router. I am using WEP128
with shared keys. Router is set to be "g" only. The OS is Fedora Core
3 (I swear I will upgrade :) ), just recompiled wireless tools from
sources in FC6.

> for debugging:
> dmesg & iwevent output would be nice...

Will do when I get home.

> but I'll accept a short "sniffer" extract too. ;)
>
> (it would be really good, if you can provide a package dump form a working
> setup with the old driver too!)
>

You'd have to tell me exactly what you want me to do.

The reason for me trying the patch is that the card locks up
frequently (the amber transmission light turns on stays this way).

-- 
Dmitry
