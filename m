From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: error out pending skbs if netlink invalidates
 incomplete neigh
Date: Thu, 11 Jun 2009 03:12:15 -0700 (PDT)
Message-ID: <20090611.031215.17106793.davem@davemloft.net>
References: <1244104855-2129-1-git-send-email-timo.teras@iki.fi>
	<20090611.030207.238260652.davem@davemloft.net>
	<4A30D781.2020403@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40135
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755166AbZFKKMN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 06:12:13 -0400
In-Reply-To: <4A30D781.2020403@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 11 Jun 2009 13:08:01 +0300

> When the state is changed to FAILED by netlink, the timer is stopped
> and further probes are not tried anymore. This results in that the
> skb's are not errored. The neigh entry is left stale.
>=20
> The behaviour is flawed currently. Either we need to prevent state
> change from INCOMPLETE -> FAILED via netlink and keep on sending
> probes,
> or flush the queue when userland replies with FAILED. Otherwise the
> neigh entry state is left bad.

Thanks for the explanation, yes this is a problem.

Can you add a little bit more verbosity to your commit message
so that this issue is clearly explained and resubmit your patch?

Thank you!
