From: Jens Osterkamp <jens@linux.vnet.ibm.com>
Subject: Re: [PATCH 43/75] spider-net: declare MODULE_FIRMWARE
Date: Mon, 9 Nov 2009 12:58:13 +0100
Message-ID: <200911091258.13989.jens@linux.vnet.ibm.com>
References: <1257630907.15927.445.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <jens@de.ibm.com>,
	netdev <netdev@vger.kernel.org>, arnd@arndb.de
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:36863 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbZKIL6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 06:58:10 -0500
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id nA9BwFpP016717
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2009 11:58:15 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nA9BwFfb2457770
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2009 11:58:15 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id nA9BwEfX019681
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2009 11:58:15 GMT
In-Reply-To: <1257630907.15927.445.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 07 November 2009, Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
>  drivers/net/spider_net.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
> index 90e663f..782910c 100644
> --- a/drivers/net/spider_net.c
> +++ b/drivers/net/spider_net.c
> @@ -57,6 +57,7 @@ MODULE_AUTHOR("Utz Bacher <utz.bacher@de.ibm.com> a=
nd
> Jens Osterkamp " \ MODULE_DESCRIPTION("Spider Southbridge Gigabit Eth=
ernet
> driver"); MODULE_LICENSE("GPL");
>  MODULE_VERSION(VERSION);
> +MODULE_FIRMWARE(SPIDER_NET_FIRMWARE_NAME);
>
>  static int rx_descriptors =3D SPIDER_NET_RX_DESCRIPTORS_DEFAULT;
>  static int tx_descriptors =3D SPIDER_NET_TX_DESCRIPTORS_DEFAULT;

In spider_net, the filesystem is checked for a valid firmware first, if=
 it=20
does not exist, the firmware is taken from the device tree (which is th=
e=20
default case).

Do you expect this behaviour to cause problems together with MODULE_FIR=
MWARE ?

--=20
Best regards,=20

Jens Osterkamp
-----------------------------------------------------------------------=
---------
IBM Deutschland Research & Development GmbH
Vorsitzender des Aufsichtsrats: Martin Jetter
Gesch=C3=A4ftsf=C3=BChrung: Erich Baier
Sitz der Gesellschaft: B=C3=B6blingen
Registergericht: Amtsgericht Stuttgart, HRB 243294

