From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: correct a comment for the final #endif
Date: Thu, 28 May 2009 08:39:35 +0200
Message-ID: <4A1E31A7.6090905@gmail.com>
References: <20090527140153.GE1652@psychotron.englab.brq.redhat.com>	<20090527.154911.39711918.davem@davemloft.net>	<20090528054712.GA20533@psychotron.englab.brq.redhat.com> <20090527.233344.74118227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53276 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbZE1Gj4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 02:39:56 -0400
In-Reply-To: <20090527.233344.74118227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Jiri Pirko <jpirko@redhat.com>
> Date: Thu, 28 May 2009 07:47:13 +0200
>=20
>> Btw how do you choose what patch to apply to what tree?
>=20
> It depends upon where we are in the development cycle and the
> nature of your patch.
>=20
> Right now we're only applying the most critical bug fixes
> to net-2.6, anything else goes to net-next-2.6
>=20

I append here some extra stuff

net-2.6 is the tree for pending patches for Linus, for the about to be
released version (2.6.30 as today)

As the merge window (for 2.6.30) is now closed, only bug fixes are allo=
wed.

=46or cleanups, and new network stuff (possibly introducing new bugs),
net-next-2.6 is the right tree. This gives time for various testers
to discover bugs so we can fix them before hitting public release.

When Linus releases 2.6.30, opening merge window of one week, then all =
patches
pending in net-next-2.6 will take their way to Linus tree for 2.6.31

Some exceptions are allowed, but this is the general idea.

Hope this helps

