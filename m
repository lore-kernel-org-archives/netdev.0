From: Ben Hoyt <benhoyt@gmail.com>
Subject: Re: Minimizing TCP latency
Date: Tue, 30 Mar 2010 15:35:27 +1300
Message-ID: <7c93bf1e1003291935k6c9060bah11e1138568ba6998@mail.gmail.com>
References: <7c93bf1e1003281829h3ddba989w198df86ac9f2d27c@mail.gmail.com>
	 <7c93bf1e1003282024p75e70011j31577b42f29cc153@mail.gmail.com>
	 <1269840891.2256.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:42950 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab0C3Cf2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 22:35:28 -0400
Received: by pwi5 with SMTP id 5so7373425pwi.19
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 19:35:28 -0700 (PDT)
In-Reply-To: <1269840891.2256.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> One machine sends messages, and messages are not aknowledged by other
> part ? Is it one way communication ?

No, it's two-way communication. It's really the round-trip
time/latency that's important.

> What are the targets ? =A0(time constraints)

We're currently seeing a round-trip time of about 40us between two
Linux servers on our network (so presumably about 20us one way).
Anything quicker than that would be nice, but we're hoping to get down
to about half that.

> Mono threaded application handling one tcp flow ?
> Are you handling a very light load on few flows, or many flows ?
> Are machines all in the same LAN ?

It's a single-threaded application handling one TCP session with light
load, maybe one or two 512-byte packets per minute. The machines are
on the same localized network. There's a (fairly high-speed) router in
between, but I think most of the delays are being introduced at the
NIC and Linux levels.

Thanks,
Ben.
