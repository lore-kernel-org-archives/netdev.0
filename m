From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: bridging with gre tunnel
Date: Mon, 14 Jul 2008 10:25:54 +0300
Message-ID: <487AFF82.4090707@iki.fi>
References: <4876FDF0.1030807@iki.fi> <487AA0CD.9090600@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:49476 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491AbYGNHZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 03:25:59 -0400
Received: by ug-out-1314.google.com with SMTP id h2so198875ugf.16
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 00:25:58 -0700 (PDT)
In-Reply-To: <487AA0CD.9090600@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Philip Craig wrote:
> Timo Ter=E4s wrote:
>> Is there newer/better patches to achieve this? Any thoughts about
>> doing bridging with gre tunnels?
>=20
> Here's a patch I did against 2.6.17.
>=20
> I didn't submit this to mainline though because the userspace ABI
> is ugly.  The basic problem is that the struct used for the ioctl
> isn't extensible.  The only way I can think of to fix it properly
> is to add configuration of gre using netlink, but I never got around
> to doing that. =20

There is an essential difference in this patch compared to the one
I referred to. This patch adds a new way to create GRE devices which
results in ethernet style device whereas the older patch modifies
transmit and receive paths to detect packets coming from bridging
code and does not need userland changes at all.

I kind of like the fact that userland tools work as-is and that
I don't need any special flags for the GRE tunnel creation. However
your patch does look way cleaner.

Any comments on what the solution to merged in should look like?

- Timo

