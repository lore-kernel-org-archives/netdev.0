From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH RFC 1/2] rhashtable: accept GFP flags in
 rhashtable_walk_init
Date: Tue, 01 Mar 2016 14:54:16 +0100
Message-ID: <1456840456.3926.22.camel@sipsolutions.net>
References: <1456708013-19590-1-git-send-email-me@bobcopeland.com>
	 (sfid-20160229_020706_258640_0460F6E4)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Bob Copeland <me@bobcopeland.com>, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35134 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753734AbcCANyU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 08:54:20 -0500
In-Reply-To: <1456708013-19590-1-git-send-email-me@bobcopeland.com> (sfid-20160229_020706_258640_0460F6E4)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-02-28 at 20:06 -0500, Bob Copeland wrote:
> In certain cases, the 802.11 mesh pathtable code wants to
> iterate over all of the entries in the forwarding table from
> the receive path, which is inside an RCU read-side critical
> section.=C2=A0=C2=A0Enable walks inside atomic sections by allowing
> GFP_ATOMIC allocations for the walker state.
>=20
> Change all existing callsites to pass in GFP_KERNEL.

Both look fine to me.

I see you have more patches for mesh, so this probably can't go through
net-next tree directly.

johannes
