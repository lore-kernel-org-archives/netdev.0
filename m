From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] caif: Fix compile warning
Date: Thu, 02 Feb 2012 14:29:20 -0500 (EST)
Message-ID: <20120202.142920.1445087235225482111.davem@davemloft.net>
References: <1328181565-13781-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290Ab2BBT32 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 14:29:28 -0500
In-Reply-To: <1328181565-13781-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Thu,  2 Feb 2012 12:19:23 +0100

> Fix compile warning:
> ... warning: statement with no effect [-Wunused-value]
> This warning is seen when debug-fs is disabled. Fix this
> by adding new macro for use when no return value is needed.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Seriously, just get rid of this debug code.

You'll feel very much relieved afterwards.
