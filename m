From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Thu, 19 Dec 2013 16:09:23 +0100
Message-ID: <20131219150923.GB24118@order.stressinduktion.org>
References: <20131219144816.33310@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Bob Falken <NetFestivalHaveFun@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39844 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469Ab3LSPJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 10:09:24 -0500
Content-Disposition: inline
In-Reply-To: <20131219144816.33310@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 03:48:16PM +0100, Bob Falken wrote:
> Hello, I have an issue after kernel 2.6.37 and above.
> If i roll back to kernel 2.6.36.4 everything is fine.
> if recive more than=C2=A04294967295 multicast packets, the kernel doe=
s not register the multicast packets. and multicast routing does not fu=
nctioning.
> (Tested bouth FIB_HASH and FIB_TRIE) =C2=A0=20
> Tested with xorp and pimd.=20
> I have abount 24 multicast groups, and it takes me=C2=A0about 17hours=
=C2=A0to reproduce the issue after a reboot.
> Reboot is reqired to fix the issue. (Tested to stop/start pimd/xorp, =
reload network module for the network interface "e1000e",
> Used birdge adapter and remove bridge adapter and readd bridge adapte=
r to clear counters. none of thouse solves the issue.)

Please test this with a recent kernel. 2.6.37 is really old and you nor=
mally
won't get good support here with such old kernels.

Greetings,

  Hannes
