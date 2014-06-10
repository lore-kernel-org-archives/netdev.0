From: Arvid Brodin <arvid.brodin@alten.se>
Subject: Re: net/hsr: not working :  High-availability Seamless Redundancy
 (HSRv0)
Date: Tue, 10 Jun 2014 17:37:37 +0200
Message-ID: <53972641.2070205@alten.se>
References: <5396FD42.1070100@kalkitech.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>
To: Gokul C G <gokul.g@kalkitech.in>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:55859 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174AbaFJPpr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 11:45:47 -0400
In-Reply-To: <5396FD42.1070100@kalkitech.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-06-10 14:42, Gokul C G wrote:
> Hi,
>=20
> I am trying to incorporate the changes made for High-availability
> Seamless Redundancy (HSRv0) in linux 3.13  into one of the older
> version  Linux 3.0.48 . I had made changes as per patch in 3.0.48
> kernel and modified  use of  NETLINK_CB(skb_in).portid to
> NETLINK_CB(skb_in).pid and info->snd_portid to info->snd_pid since
> the variable are renamed recently for better readability , added new
> list related  macro(like list_for_each_entry_rcu) to old kernel .
>=20
> I am doing this for a Big-endian system with powerpc architecture
> with real-time functionality enabled . The kernel occurred while
> probing hsr/prp driver and following  console information available.
> I had tried to compile HSRv0 driver with kernel and also as kernel
> module , in both cases following crash message found on console.
>=20

This is of course impossible for anyone else but yourself to debug,=20
since noone else has access to the exact code you are using.

If you are able to recreate the bug on a current, vanilla kernel,=20
someone might be able to help.


--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
