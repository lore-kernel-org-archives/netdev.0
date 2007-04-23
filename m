From: David Miller <davem@davemloft.net>
Subject: Re: Problem with commit a0ee18b9b7d3847976c6fb315c06a34fb296de0e
Date: Mon, 23 Apr 2007 11:51:25 -0700 (PDT)
Message-ID: <20070423.115125.97295475.davem@davemloft.net>
References: <200704231506.34410.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: ismail@pardus.org.tr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33955
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161464AbXDWSvY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 14:51:24 -0400
In-Reply-To: <200704231506.34410.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ismail D=F6nmez <ismail@pardus.org.tr>
Date: Mon, 23 Apr 2007 15:06:34 +0300

> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -89,7 +89,7 @@ static const struct
>  {
>         int     error;
>         u8      scope;
> -} fib_props[RTA_MAX + 1] =3D {
> +} fib_props[RTN_MAX + 1] =3D {

This fix is already in the net-2.6.22 tree.
