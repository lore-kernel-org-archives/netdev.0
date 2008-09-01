From: Andi Kleen <andi@firstfloor.org>
Subject: Re: IPv6 tunnel scalability problem
Date: Mon, 01 Sep 2008 14:04:58 +0200
Message-ID: <8763pgxead.fsf@basil.nowhere.org>
References: <200808311958.51510.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Bernhard Schmidt <berni+ipv6@birkenwald.de>
To: =?utf-8?Q?R=C3=A9mi?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:45088 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbYIAMFA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 08:05:00 -0400
In-Reply-To: <200808311958.51510.rdenis@simphalempin.com> (=?utf-8?Q?R?=
 =?utf-8?Q?=C3=A9mi?= Denis-Courmont's message of "Sun, 31 Aug 2008 19:58:51
 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=C3=A9mi Denis-Courmont <rdenis@simphalempin.com> writes:

> I have been maintaining a TUN-based Linux implementation of Teredo/RF=
C4380. On=20
> a busy node, this can trigger quite many peers on the virtual point-t=
o-point=20
> tunnel interface. I have received complaints that the whole thing see=
ms to=20
> hit some severe performance bottleneck when this happens. It is not c=
lear to=20
> me at this point whether it's a kernel or a user problem. So I have b=
een=20
> writing a stress test.

You could use oprofile to find out where the CPU time is going.
That would work even during normal operation. Post the opreport -l outp=
ut

-Andi

--=20
ak@linux.intel.com
