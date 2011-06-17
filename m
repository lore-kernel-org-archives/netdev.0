From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] caif: Bugfix - XOFF removed channel from
 caif-mux
Date: Thu, 16 Jun 2011 23:59:25 -0400 (EDT)
Message-ID: <20110616.235925.1279028057490215583.davem@davemloft.net>
References: <1308177505-1843-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756993Ab1FQD7a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:59:30 -0400
In-Reply-To: <1308177505-1843-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Thu, 16 Jun 2011 00:38:25 +0200

> XOFF was mixed up with DOWN indication, causing causing CAIF channel =
to be
> removed from mux and all incoming traffic to be lost after receiving =
flow-off.
> Fix this by replacing FLOW_OFF with DOWN notification.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied, thanks.
