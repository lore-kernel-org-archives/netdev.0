From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.23-rc8-mm2] Fix a compile problem in macb.c
Date: Tue, 02 Oct 2007 13:31:58 -0400
Message-ID: <4702808E.1050601@garzik.org>
References: <1191338603393-git-send-email-hskinnemoen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	=?ISO-8859-1?Q?Hans-J=FCrgen_Koch?= <hjk@linutronix.de>
To: Haavard Skinnemoen <hskinnemoen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49389 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753979AbXJBRcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 13:32:04 -0400
In-Reply-To: <1191338603393-git-send-email-hskinnemoen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Haavard Skinnemoen wrote:
> From: Hans-J=C3=BCrgen Koch <hjk@linutronix.de>
>=20
> Compiling macb.c fails because the type of parameter 2 of macb_poll()
> was changed from int* to int. Furthermore, a local variable was remov=
ed
> but was still used inside the function. This patch fixes it.
>=20
> Signed-off-by: Hans J. Koch <hjk@linutronix.de>
> Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
> ---
>  drivers/net/macb.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

applied


