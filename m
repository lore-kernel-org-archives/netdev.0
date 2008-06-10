From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] bondig - arp_interval with low value => Oops.
Date: Tue, 10 Jun 2008 18:39:28 -0400
Message-ID: <484F02A0.7010009@garzik.org>
References: <482C9E73.2040202@free.fr> <484EFDFC.3040206@garzik.org> <8135.1213137006@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas 2P <nicolas.2p.debian@free.fr>,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40370 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753375AbYFJWjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:39:42 -0400
In-Reply-To: <8135.1213137006@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Jeff Garzik <jeff@garzik.org> wrote:
>=20
>> Nicolas 2P wrote:
>>> When setting arp_interval parameter to a very low value, delta_in_t=
icks
>>> for next arp might become 0, causing an infinite loop.
>>>
>>> See http://bugzilla.kernel.org/show_bug.cgi?id=3D10680
>>>
>>> Same problem for miimon parameter already fixed, but fix might be
>>> enhanced, by using msecs_to_jiffies() function.
>>>
>>> Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
>> I don't see an ACK from Jay in my mbox?
>>
>> Certainly looks nicer than adding "? : 1" to each of the remaining t=
wo
>> cases.
>=20
> 	This was accepted a couple of weeks ago; I had to fix a bug in
> the patch, so I'd guess you didn't connect them:
>=20
> commit 5ce0da8f0386b62345312ec8fed31303732f4220
> Author: Jay Vosburgh <fubar@us.ibm.com>
> Date:   Sat May 17 21:10:07 2008 -0700
>=20
>     bonding: Use msecs_to_jiffies, eliminate panic

Great, thanks!


