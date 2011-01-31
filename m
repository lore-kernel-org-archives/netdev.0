From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2 16/16] skge: convert to hw_features
Date: Mon, 31 Jan 2011 08:45:02 -0800
Message-ID: <20110131084502.7be146e7@nehalam>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
	<34b51af1d2b880439d2d210837fc87a89c0b9ec4.1295734271.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56255 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab1AaQpF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 11:45:05 -0500
In-Reply-To: <34b51af1d2b880439d2d210837fc87a89c0b9ec4.1295734271.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 22 Jan 2011 23:14:14 +0100 (CET)
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> The hardware might do full HW_CSUM, not just IP_CSUM, but it's not te=
sted
> and so not changed here.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

The skge hardware does not do full HW_CSUM. It looks at the IP header.
