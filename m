From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ip_no_pmtu_disc and UDP
Date: Tue, 27 Oct 2015 00:08:22 +0100
Message-ID: <1445900902.1799544.420940873.09BD42C3@webmail.messagingengine.com>
References: <CAK3+h2wFfh+HE78kHoWwgc9vyTCLWM90C4RQ=uTRk8551-jQ7A@mail.gmail.com>
 <1445639662.2872263.418778169.006CB827@webmail.messagingengine.com>
 <CAK3+h2y3AiN7byuw2ihBohbu+TmOs2ursBvvsL5rwd32MYDGYA@mail.gmail.com>
 <1445897546.1785067.420905281.288C3AF1@webmail.messagingengine.com>
 <CAK3+h2x4qXJsgwnon98OZoua7=z1bEoOYJTn1yKYE5k046AO9A@mail.gmail.com>
 <CAK3+h2yvx2gh1WoTD4=-OPv5VxyfHO7ZJ4qgZcuwyAn77d6Q+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:32850 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751998AbbJZXIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 19:08:23 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 84B1820913
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 19:08:22 -0400 (EDT)
In-Reply-To: <CAK3+h2yvx2gh1WoTD4=-OPv5VxyfHO7ZJ4qgZcuwyAn77d6Q+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2015, at 23:53, Vincent Li wrote:
> ok, I observed  if i increase the UDP client packet size > local
> interface  MTU 1500, the client will fragment the packet first and
> then send it out, if the UDP client packet size < local interface MTU
> 1500, the DF bit will be set when ip_no_pmtu_disc set to 0, is this
> expected behavior ?

Yes, it is.

Bye,
Hannes
