From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Fwd: RFC 6980 on Security Implications of IPv6 Fragmentation with IPv6 Neighbor Discovery
Date: Thu, 15 Aug 2013 12:25:07 +0200
Message-ID: <20130815102507.GA24122@order.stressinduktion.org>
References: <20130813221321.AEA1AB1E003@rfc-editor.org> <520B3D81.9070506@gont.com.ar> <20130814230617.GA13066@order.stressinduktion.org> <520C7519.1010000@gont.com.ar> <20130815100407.GA18564@order.stressinduktion.org> <CAOp4FwRx3c3deHXupWg3S0aWe4ZJnCT9ORKCWRvUUuxxt1gneQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Fernando Gont <fernando@gont.com.ar>,
	netdev <netdev@vger.kernel.org>
To: Loganaden Velvindron <loganaden@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53315 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579Ab3HOKZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 06:25:09 -0400
Content-Disposition: inline
In-Reply-To: <CAOp4FwRx3c3deHXupWg3S0aWe4ZJnCT9ORKCWRvUUuxxt1gneQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 02:14:46PM +0400, Loganaden Velvindron wrote:
> I'm not sure if you got my previous mails, but I'd like to know a
> couple of things:

Ah, you asked me off-list. So, for a wider audience, I copy & paste my answers
from the just answered mail. ;)

> 1) How can I test this diff ?

Actually, nothing should change at all.

Myself, I used scapy to construct some packets and send it to a system
with the patched kernel and had some printks sprinkeled in the source
while watching tcpdump.

> 2) It's developed against which git brach ? linux-next ?

Yes, I targeted linux-next. But it should apply to older kernels
without too much fuzz as well.

> 3) What will/could break with this diff in a production environment ?

RA messages could get fragmented if a speaker puts lots of options in it. I
hope all RA speakers already spread the options over multiple RAs, but I don't
know. In case the RA is fragmented it will now be dropped silently.

Thanks,

  Hannes
