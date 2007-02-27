From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: need some help on a backport of r8169
Date: Tue, 27 Feb 2007 22:24:00 +0100
Message-ID: <20070227212400.GA12760@electric-eye.fr.zoreil.com>
References: <20070226170941.GA17587@venus.synerway.com> <20070226234831.GA12830@electric-eye.fr.zoreil.com> <20070227110243.GA15657@venus.synerway.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Pascal GREGIS <pgs@synerway.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55545 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752563AbXB0V06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 16:26:58 -0500
Content-Disposition: inline
In-Reply-To: <20070227110243.GA15657@venus.synerway.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please don't do > 80 columns line again. I am not a tty.

Pascal GREGIS <pgs@synerway.com> :
> Francois Romieu a =E9crit, le Tue 27 Feb 2007 =E0 12:48:31AM :
[...]
> Where is this init sequence in the driver? I searched in the code and
> didn't find something that could satisfy, then I took the 2.6.12.3 r8=
169.c,

See hw_start.

> put it in the 2.6.11.11 source tree, applied my patch, changed
> synchronize_sched(); to synchronize_kernel(); because the symbol was
> unknown and then I could turn eth1 on and assign it an ip address but=
 the
> rx and tx count never grew and when I turned eth0 down (a 8139 card) =
eth1
> didn't reply to ping anymore.

Linux kernel 2.6.12 does not support the 8168 (it includes some 8169 fi=
xes
though).

[...]
> > There are 59 r8169 related patches between 2.6.12 and current. Only=
 a few
> > of those break the API. I'll give it a try tomorrow evening.
> Hmm... you wrote this mail at 00 h 48 this morning, what did you mean=
 by
> tomorrow evening?

1. I mean now. See:
   http://www.fr.zoreil.com/people/francois/backport/r8169/20070227-00
   (big patch or serie of 54 pieces).

2. Compiled, untested. You know what you have to do.

3. Due to the changes in the driver, one could hope that the link will =
be
   autocorrectly set. Please give it a try before using ethtool/mii-too=
l.

4. The patchkit does not include the latest changes/bugfixes. They are
   still experimental but some users have a poor 8168 experience withou=
t
   them. YMMV. Please send a complete dmesg, lspci -vvx and the brand o=
f
   the motherboard if the driver stops working randomly.

--=20
Ueimor
