From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] skge: convert to hw_features
Date: Thu, 31 Mar 2011 08:41:02 -0700
Message-ID: <20110331084102.71eb2b55@nehalam>
References: <20110331110135.9625513A68@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51452 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753146Ab1CaPlL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 11:41:11 -0400
In-Reply-To: <20110331110135.9625513A68@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Mar 2011 13:01:35 +0200 (CEST)
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> >From the code it looks like the hardware might support full HW_CSUM =
not
> just IP_CSUM.  This needs testing and so is not changed here.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

I don't think this will work right. The old code did not allow setting
tx/rx csum on the older GENESIS chip,=20

--=20
