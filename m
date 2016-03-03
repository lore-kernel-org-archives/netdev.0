From: Bob Copeland <me@bobcopeland.com>
Subject: Re: [PATCH 1/2] rhashtable: accept GFP flags in rhashtable_walk_init
Date: Thu, 3 Mar 2016 10:41:52 -0500
Message-ID: <20160303154152.GE19848@localhost>
References: <1456931360-2846-1-git-send-email-me@bobcopeland.com>
 <1457018779.2044.22.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33888 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755699AbcCCPmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 10:42:09 -0500
Received: by mail-qg0-f48.google.com with SMTP id w104so19963178qge.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 07:42:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1457018779.2044.22.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2016 at 04:26:19PM +0100, Johannes Berg wrote:
> On Wed, 2016-03-02 at 10:09 -0500, Bob Copeland wrote:
> > In certain cases, the 802.11 mesh pathtable code wants to
> > iterate over all of the entries in the forwarding table from
> > the receive path, which is inside an RCU read-side critical
> > section.=A0=A0Enable walks inside atomic sections by allowing
> > GFP_ATOMIC allocations for the walker state.
> >=20
> > Change all existing callsites to pass in GFP_KERNEL.
>=20
> Applied both. You missed 3 callsites, I've fixed those. I hope I got
> them all :)

Ouch, thanks for the catch, I must've grepped only in net.
And now I added those files to my build config. :)

--=20
Bob Copeland %% http://bobcopeland.com/
