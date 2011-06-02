From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: Fix race when conditionally taking rtnl lock
Date: Wed, 01 Jun 2011 21:14:07 -0700 (PDT)
Message-ID: <20110601.211407.961267361520373791.davem@davemloft.net>
References: <1306925737-1782-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab1FBEOO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 00:14:14 -0400
In-Reply-To: <1306925737-1782-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Wed,  1 Jun 2011 12:55:37 +0200

> Take the RTNL lock unconditionally when calling dev_close.
> Taking the lock conditionally may cause race conditions.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied, thanks.
