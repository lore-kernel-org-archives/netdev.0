From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 00/15]: TCP rexmit changes
Date: Sat, 20 Sep 2008 21:32:32 -0700 (PDT)
Message-ID: <20080920.213232.115194384.davem@davemloft.net>
References: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51027
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750735AbYIUEco convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Sep 2008 00:32:44 -0400
In-Reply-To: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sun, 21 Sep 2008 00:47:43 +0300

> John Heffner noted ages ago that TCP does O(n^2) processing
> during recovery. SACKtag part was solved earlier, making
> duplicate ACKs to avoid scanning the write queue unnecessarily.
> This change is intented to (mostly) solve the periods when
> cumulative ACKs occur during a recovery, ie., basically when
> the situation starts to resolve.
>=20
> v2 fixes !tp->lost_out detection in case we went already more
> than 2^31 from the previous retransmit_high.
>=20
> I played again with it a bit, this time I also went to see the
> counters using systemtap and afaict the counters matched what
> I expected to see (fwd-rexmits and some other cases related to
> collapse/fragment weren't covered by my simple transfer).

These changes look great, all applied to net-next-2.6

Thanks a lot!
