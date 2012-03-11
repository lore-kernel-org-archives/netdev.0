From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] caif: Fix for a race in socket transmit
 with flow control.
Date: Sun, 11 Mar 2012 15:38:32 -0700 (PDT)
Message-ID: <20120311.153832.1595701722068992237.davem@davemloft.net>
References: <1331497712-13534-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	dmitry.tarnyagin@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab2CKWii convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 18:38:38 -0400
In-Reply-To: <1331497712-13534-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Sun, 11 Mar 2012 21:28:31 +0100

> From: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>
>=20
> Kill faulty checks on flow-off leading to connection drop at race con=
ditions.
> caif_socket checks for flow-on before transmitting and goes to sleep =
or
> return -EAGAIN upon flow stop. Remove faulty subsequent checks on flo=
w-off
> leading to connection drop. Also fix memory leaks on some of the erro=
rs paths.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
