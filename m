From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] rhashtable: accept GFP flags in rhashtable_walk_init
Date: Thu, 03 Mar 2016 16:26:19 +0100
Message-ID: <1457018779.2044.22.camel@sipsolutions.net>
References: <1456931360-2846-1-git-send-email-me@bobcopeland.com>
	 (sfid-20160302_160933_050886_E6CBBDD5)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	netdev@vger.kernel.org
To: Bob Copeland <me@bobcopeland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56557 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512AbcCCP00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 10:26:26 -0500
In-Reply-To: <1456931360-2846-1-git-send-email-me@bobcopeland.com> (sfid-20160302_160933_050886_E6CBBDD5)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-03-02 at 10:09 -0500, Bob Copeland wrote:
> In certain cases, the 802.11 mesh pathtable code wants to
> iterate over all of the entries in the forwarding table from
> the receive path, which is inside an RCU read-side critical
> section.=C2=A0=C2=A0Enable walks inside atomic sections by allowing
> GFP_ATOMIC allocations for the walker state.
>=20
> Change all existing callsites to pass in GFP_KERNEL.

Applied both. You missed 3 callsites, I've fixed those. I hope I got
them all :)

johannes
