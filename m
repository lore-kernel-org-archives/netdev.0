From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6: Blackhole route support partial ?
Date: Thu, 14 Nov 2013 15:11:49 +0100
Message-ID: <20131114141149.GC26901@order.stressinduktion.org>
References: <CAP8BHkGZ5EFxW4BNervKrOiEaQTNdSh9s2YOrFoexzQCOR=AqQ@mail.gmail.com> <20131111203954.GB3043@order.stressinduktion.org> <CAP8BHkG6=KuU9K7=sGsZftMDe58eTYByRu2DZ+j+KNqcfsOfAA@mail.gmail.com> <20131112135412.GF14929@order.stressinduktion.org> <CAP8BHkEyASA52Q4Zg4w5OqR7Hv7Y_it8SnG_tMPViza_T9TV+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kamala R <kamala@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42819 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987Ab3KNOLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:11:50 -0500
Content-Disposition: inline
In-Reply-To: <CAP8BHkEyASA52Q4Zg4w5OqR7Hv7Y_it8SnG_tMPViza_T9TV+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Thu, Nov 14, 2013 at 01:50:20PM +0530, Kamala R wrote:
> I have one quick question before I send the patch across. I noticed
> that "ip -6 route show" shows an error -22 in the output which
> signifies -EINVAL associated with blackhole routes. This behaviour is
> not consistent with that of "ip route show" that shows no such error
> for a blackhole route. Does this qualify a bug that needs fixing ?

You mean that we don't show the error for IPv4 routes? Is this a kernel or
iproute problem?

Greetings,

  Hannes
