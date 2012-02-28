From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fix tcp_shifted_skb() adjustment of lost_cnt_hint
 for FACK
Date: Mon, 27 Feb 2012 23:42:28 -0500
Message-ID: <CADVnQy=955yH2qJX=Pi=jizQRfgSHuUNu-i7NwXzQrJQBSNAxA@mail.gmail.com>
References: <CADVnQym_a=QDyjGX=L6-o3orxPdKJOwVZNfutaW5ZHAt=aB21A@mail.gmail.com>
	<20120227.215820.1289745868005567561.davem@davemloft.net>
	<CADVnQy=YkDOGX66ycPuPCy9TigXN1k4cDpSrK1Wq8zK_xBYi8A@mail.gmail.com>
	<20120227.233105.919773668237455042.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ilpo.jarvinen@helsinki.fi, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, nanditad@google.com, ycheng@google.com,
	therbert@google.com, subramanian.vijay@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:48334 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388Ab2B1Em3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 23:42:29 -0500
Received: by iagj37 with SMTP id j37so716042iag.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 20:42:28 -0800 (PST)
In-Reply-To: <20120227.233105.919773668237455042.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2012 at 11:31 PM, David Miller <davem@davemloft.net> wrote:
>> OK, sounds good to me. In that case I think it would be good to have
>> the http://patchwork.ozlabs.org/patch/143114/ patch in -stable as
>> well, since having just the three patches above would leave us with a
>> known reordering issue.
>
> I'll make sure it hits the -stable release after the one Greg is
> trying to put out right now.

Great. Thanks!

> The change you reference rarely matters as most of the time it passes
> a degreee of reordering of one.

Yep.

neal
