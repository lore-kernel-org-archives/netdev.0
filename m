From: James Morris <jmorris@redhat.com>
Subject: Re: your mail
Date: Tue, 13 Apr 2004 09:46:11 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Xine.LNX.4.44.0404130945460.14102-100000@thoron.boston.redhat.com>
References: <200404121623.42558.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>,
	=?iso-2022-jp?Q?YOSHIFUJI_Hideaki_=2F_=1B$B5HF#1QL=40=1B=28B?=
	<yoshfuji@linux-ipv6.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200404121623.42558.vda@port.imtp.ilyichevsk.odessa.ua>
List-Id: netdev.vger.kernel.org

On Mon, 12 Apr 2004, Denis Vlasenko wrote:

> According to my measurements,
>=20
> ip_vs_control_add() (from include/net/ip_vs.h) is called twice
> and
> sock_queue_rcv_skb() (from=A0include/net/sock.h) is called 19 times
> from various kernel .c files.
>=20
> Both these includes generate more than 500 bytes of code on x86.
>=20
> These patches uninline them. Please apply.

What kind of performance impact (if any) does this patch have?


- James
--=20
James Morris
<jmorris@redhat.com>
