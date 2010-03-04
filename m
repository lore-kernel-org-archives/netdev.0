From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Iproute2 tc pfifo_fast not work
Date: Thu, 4 Mar 2010 08:40:16 -0800
Message-ID: <20100304084016.052a7044@nehalam>
References: <4B8F7537.7090008@electro-com.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?0J/QtdGC0YPRhdC+0LIg0JTQvNC40YLRgNC40Lk=?=
	<d.petuhov@electro-com.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46753 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755550Ab0CDQkz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 11:40:55 -0500
In-Reply-To: <4B8F7537.7090008@electro-com.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 Mar 2010 11:54:15 +0300
=D0=9F=D0=B5=D1=82=D1=83=D1=85=D0=BE=D0=B2 =D0=94=D0=BC=D0=B8=D1=82=D1=80=
=D0=B8=D0=B9 <d.petuhov@electro-com.ru> wrote:

> Hi Stephen.
>=20
> I've found that I can't add pfifo_fast qdisc to my tc class tree. It=20
> just says:
> -----------
> # /sbin/tc qdisc add dev eth3 parent 2:299B handle 299B: pfifo_fast
> qdisc 'pfifo_fast' does not support option parsing
> -----------
> And nothing else happends.
> strace /sbin/tc qdisc add dev eth3 parent 2:299B handle 299B: pfifo_f=
ast=20
> &> tc_pfifo_strace.txt
> attached.
>=20
> Kernel version 2.6.31, .config attached.
> tc version 2.6.31.
>=20
> I do something wrong or this is a bug?
no

> For now I've switched to PRIO QDISC which seems to work fine, but it=20
> would be great to use lithweigth pfifo_fast instead of prio...

pfifo_fast is very limited to being just a root qdisc, and with no
children.  If you want to do the same thing but in other context
just use pfifo.


