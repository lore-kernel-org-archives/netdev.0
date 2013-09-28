From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path MTU discovery broken
Date: Sat, 28 Sep 2013 22:33:18 +0200
Message-ID: <20130928203318.GC23654@order.stressinduktion.org>
References: <20130927201420.GB12043@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, edumazet@google.com
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57499 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755097Ab3I1UdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 16:33:19 -0400
Content-Disposition: inline
In-Reply-To: <20130927201420.GB12043@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Fri, Sep 27, 2013 at 10:14:20PM +0200, Steinar H. Gunderson wrote:
> So the =E2=80=9Cpacket too big=E2=80=9D packets really look like they=
're being ignored.
> However, they _do_ reach the kernel somehow, since Icmp6InPktTooBigs
> seems to increase.
>=20
> Could this be related somehow to the packets coming from 2001:67c:29f=
4::31,
> while the default route is to a link-local address? (An RPF issue?) T=
his used
> to work (although it was often flaky for me) in 3.10 and before. I ca=
n't
> easily bisect, though, as I don't boot this machine too often.

This looks like a bug and should definitely get fixed. There should be
no RPF issue. May I have a look at your /proc/net/ipv6_route?

Thanks,

  Hannes
