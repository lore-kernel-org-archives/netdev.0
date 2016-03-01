From: Bob Copeland <me@bobcopeland.com>
Subject: Re: [PATCH RFC 1/2] rhashtable: accept GFP flags in
 rhashtable_walk_init
Date: Tue, 1 Mar 2016 09:15:11 -0500
Message-ID: <20160301141511.GC19848@localhost>
References: <1456708013-19590-1-git-send-email-me@bobcopeland.com>
 <1456840456.3926.22.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:33747 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbcCAOPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 09:15:24 -0500
Received: by mail-qg0-f46.google.com with SMTP id d32so86521690qgd.0
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 06:15:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456840456.3926.22.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2016 at 02:54:16PM +0100, Johannes Berg wrote:
> On Sun, 2016-02-28 at 20:06 -0500, Bob Copeland wrote:
> > In certain cases, the 802.11 mesh pathtable code wants to
> > iterate over all of the entries in the forwarding table from
> > the receive path, which is inside an RCU read-side critical
> > section.=A0=A0Enable walks inside atomic sections by allowing
> > GFP_ATOMIC allocations for the walker state.
> >=20
> > Change all existing callsites to pass in GFP_KERNEL.
>=20
> Both look fine to me.
>=20
> I see you have more patches for mesh, so this probably can't go throu=
gh
> net-next tree directly.

Yeah, these two are on top of the other mesh path table changes.

So either both of these could go via mac80211-next or we could do the
1/2 in net-next and wait to apply 2/2 in mac80211-next.  Whatever works
for you guys.

--=20
Bob Copeland %% http://bobcopeland.com/
