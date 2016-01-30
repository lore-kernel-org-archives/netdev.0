From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] fib_trie: Fix shift by 32 in fib_table_lookup
Date: Fri, 29 Jan 2016 19:42:06 -0800 (PST)
Message-ID: <20160129.194206.1773523483172152733.davem@davemloft.net>
References: <20160128214224.11296.99019.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbcA3DmH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 22:42:07 -0500
In-Reply-To: <20160128214224.11296.99019.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Alexander Duyck <aduyck@mirantis.com>
Date: Thu, 28 Jan 2016 13:42:24 -0800

> The fib_table_lookup function had a shift by 32 that triggered a UBSA=
N
> warning.  This was due to the fact that I had placed the shift first =
and
> then followed it with the check for the suffix length to ignore the
> undefined behavior.  If we reorder this so that we verify the suffix =
is
> less than 32 before shifting the value we can avoid the issue.
>=20
> Reported-by: Toralf F=F6rster <toralf.foerster@gmx.de>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied.
