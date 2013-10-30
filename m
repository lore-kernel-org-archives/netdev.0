From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tipc: remove two indentation levels in
 tipc_recv_msg routine
Date: Wed, 30 Oct 2013 16:54:43 -0400 (EDT)
Message-ID: <20131030.165443.2187198550218718303.davem@davemloft.net>
References: <1383103617-28813-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David.Laight@aculab.com, maloy@donjonn.com,
	Paul.Gortmaker@windriver.com, jon.maloy@ericsson.com,
	erik.hugne@ericsson.com, andreas.bofjall@ericsson.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab3J3Uyu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 16:54:50 -0400
In-Reply-To: <1383103617-28813-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ying Xue <ying.xue@windriver.com>
Date: Wed, 30 Oct 2013 11:26:57 +0800

> The message dispatching part of tipc_recv_msg() is wrapped layers of
> while/if/if/switch, causing out-of-control indentation and does not
> look very good. We reduce two indentation levels by separating the
> message dispatching from the blocks that checks link state and
> sequence numbers, allowing longer function and arg names to be
> consistently indented without wrapping. Additionally we also rename
> "cont" label to "discard" and add one new label called "unlock_discar=
d"
> to make code clearer. In all, these are cosmetic changes that do not
> alter the operation of TIPC in any way.
>=20
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Cc: David Laight <david.laight@aculab.com>
> Cc: Andreas Bofj=E4ll <andreas.bofjall@ericsson.com>
> ---
> v2: Incorporated comments from David Laight and Andreas Bofj=E4ll

This patch looks good, applied, thanks.
