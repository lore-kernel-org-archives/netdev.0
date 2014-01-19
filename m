From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Sun, 19 Jan 2014 19:18:06 +0100
Message-ID: <20140119181806.GC16462@order.stressinduktion.org>
References: <20140118191107.GA21979@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49771 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbaASSSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 13:18:08 -0500
Content-Disposition: inline
In-Reply-To: <20140118191107.GA21979@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 18, 2014 at 08:11:07PM +0100, Steinar H. Gunderson wrote:
> It doesn't matter if I drop the =E2=80=9Cmulticast=E2=80=9D token fro=
m the ip route line.
> Behavior is still exactly the same; it comes out of eth0 instead of e=
th0.2,
> with the wrong source address.
>=20
> This used to work, once upon a time, but I fear it broke during a
> kernel upgrade. It's hard for me to say exactly when; probably
> a few months ago. Any ideas?

I currently only remember one commit 0a7e22609067ff ("ipv4: fix
ineffective source address selection") which did affect multicast sourc=
e
address selection in recent times.

Maybe try a revert?

Greetings,

  Hannes
