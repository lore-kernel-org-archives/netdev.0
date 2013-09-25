From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 v2] net: Add function to get SW rxhash
Date: Tue, 24 Sep 2013 17:17:37 -0700
Message-ID: <1380068257.3165.130.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309241335380.23856@tomh.mtv.corp.google.com>
	 <1380058203.3165.121.camel@edumazet-glaptop>
	 <CA+mtBx94yRWRNkfcbkOmFhMcspdyb-Q=jn0=dkAVTZrj-XFCDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:53740 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288Ab3IYARi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 20:17:38 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so5295351pdj.35
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 17:17:38 -0700 (PDT)
In-Reply-To: <CA+mtBx94yRWRNkfcbkOmFhMcspdyb-Q=jn0=dkAVTZrj-XFCDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 15:16 -0700, Tom Herbert wrote:
>  If it's a big win for conntrack to process packets on same CPUs for
> both directions, we should program the RFS table to accomplish that.

conntrack uses no userland code, no user thread, so what are you going
to put in RFS table ?

Right now, RPS can be used for proper steering, you only have to
"ethtool -K eth{x} rxhash off"

[ Of course, this is becoming less a concern with multiqueue nics ]
