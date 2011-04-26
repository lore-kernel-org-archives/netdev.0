From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 26 Apr 2011 18:58:58 +0200
Message-ID: <BANLkTikcn832pXzxPjM032ZuRi8o0SQ++Q@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	<1303730701.2747.110.camel@edumazet-laptop>
	<BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
	<1303745915.2747.151.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Carsten Wolff <carsten@wolffcarsten.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41231 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753391Ab1DZQ7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 12:59:01 -0400
Received: by iyb14 with SMTP id 14so665693iyb.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 09:59:01 -0700 (PDT)
In-Reply-To: <1303745915.2747.151.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, Apr 25, 2011 at 5:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Since you have at sender a rule to spoof destination address of packets,
> you should make sure you dont send "super packets (up to 64Kbytes)",
> because it would stress the multipath more than you wanted to. This way,
> you send only normal packets (1500 MTU).
>
> ethtool -K eth0 tso off
> ethtool -K eth0 gso off
>
> I am pretty sure it should help your (atypic) workload.

I made new experiments with the exact same multipath setup as before,
but disabled TSO and GSO on all involved Ethernet interfaces. However,
this did not seem to change much about TCP's behavior when packets are
striped over heterogeneous paths. You can see the results of four
20-minute experiments on this plot:

http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-01-tos0.png

Cheers,
Dominik
