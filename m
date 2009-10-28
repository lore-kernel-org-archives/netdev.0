From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN exchange
 with SYNACK data
Date: Wed, 28 Oct 2009 15:17:34 +0100
Message-ID: <4AE8527E.4080603@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40133 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753583AbZJ1ORc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 10:17:32 -0400
In-Reply-To: <4AE6E7C0.2050408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> This is a significantly revised implementation of an earlier (year-ol=
d)
> patch that no longer applies cleanly, with permission of the original
> author (Adam Langley).  That patch was previously reviewed:
>=20
>    http://thread.gmane.org/gmane.linux.network/102586
>=20
> The principle difference is using a TCP option to carry the cookie no=
nce,
> instead of a user configured offset in the data.  This is more flexib=
le and
> less subject to user configuration error.  Such a cookie option has b=
een
> suggested for many years, and is also useful without SYN data, allowi=
ng
> several related concepts to use the same extension option.
>=20
>    "Re: SYN floods (was: does history repeat itself?)", September 9, =
1996.
>    http://www.merit.net/mail.archives/nanog/1996-09/msg00235.html

Sorry this link might be interesting to you, but I found nothing that e=
xplains
your patches.

>=20
>    "Re: what a new TCP header might look like", May 12, 1998.
>    ftp://ftp.isi.edu/end2end/end2end-interest-1998.mail

Same here....

>=20
> Data structures are carefully composed to require minimal additions.
> For example, the struct tcp_options_received cookie_plus variable fit=
s
> between existing 16-bit and 8-bit variables, requiring no additional
> space (taking alignment into consideration).  There are no additions =
to
> tcp_request_sock, and only 1 pointer and 1 flag byte in tcp_sock.
>=20
> Allocations have been rearranged to avoid requiring GFP_ATOMIC, with
> only one unavoidable exception in tcp_create_openreq_child(), where t=
he
> tcp_sock itself is created GFP_ATOMIC.
>=20
> These functions will also be used in subsequent patches that implemen=
t
> additional features.
>=20
> Requires:
>   TCPCT part 1a: add request_values parameter for sending SYNACK
>   TCPCT part 1b: sysctl_tcp_cookie_size, socket option
> TCP_COOKIE_TRANSACTIONS, functions
>=20
> Signed-off-by: William.Allen.Simpson@gmail.com

I tried to find an RFC or document about this stuff and failed.

Before reading implementation code, I like to have english text that de=
scribes
the new concept/design.

(BTW I found http://ttcplinux.sourceforge.net/theses/ETTCP.pdf and foun=
d it interesting,
I wonder what happened to this)

