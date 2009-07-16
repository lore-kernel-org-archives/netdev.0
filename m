From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: e1000e 2.6.30.1 massive packet loss
Date: Thu, 16 Jul 2009 10:04:07 +0200
Message-ID: <4A5EDEF7.7090303@cosmosbay.com>
References: <81bfc67a0907160049q3d43093cy52276f0fe1157d89@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59733 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752754AbZGPIEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 04:04:14 -0400
In-Reply-To: <81bfc67a0907160049q3d43093cy52276f0fe1157d89@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Caleb Cushing a =C3=A9crit :
> So from 2.6.30 to .1 I noticed that via an icmp test (mtr) 20-50%
> packet loss web browsing became impractical (downgrading fixed the
> issue). I'm wondering if the change to the driver (w/ msi) is the
> cause? also wondering if this is known and will be fixed in .2 I can
> provide more information if necessary.
>=20

Added netdev to get more attention to this.

What do you call 20-50% packet loss ?
(Losses to icmp flood itself, or tcp losses ?
Is the machine answering to icmp flood, or is it the origin ?

Are you saying packet loss was not occurring with 2.6.30 ?

Could you describe your methodology ?

You could give us results of "cat /proc/interrupts" from both
versions, because it sounds as an interrupt affinity problem.

# cat /proc/interrupts
# tc -s -d qdisc
# ifconfig -a
