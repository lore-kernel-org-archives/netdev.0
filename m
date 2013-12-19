From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HW accelerated support for setting skb->pkt_type?
Date: Wed, 18 Dec 2013 18:56:42 -0800
Message-ID: <1387421802.19078.345.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAGVrzca0P64D181XHjcXMOSMMsyyOEEGjH2KO9bChnN0dAbaTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:63070 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab3LSC4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 21:56:31 -0500
Received: by mail-pa0-f54.google.com with SMTP id rd3so519780pab.41
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 18:56:30 -0800 (PST)
In-Reply-To: <CAGVrzca0P64D181XHjcXMOSMMsyyOEEGjH2KO9bChnN0dAbaTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-18 at 18:29 -0800, Florian Fainelli wrote:
> Hi all,
> 
> I work with two Ethernet controllers which can tell on a per-packet
> basis whether this is a broadcast, unicast or multicast, eventually
> allowing me to bypass the initial checks done in eth_type_trans().
> 
> Is there any other hardware out there which supports that, and is
> there any interest in optimizing that operation?

Other hardware have this as well, but I doubt it makes any difference,
unless you have an arch with a 16 bytes cache line.
