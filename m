From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 09/10] [TCP]: Rewrite SACK block processing &
 sack_recv_cache use
Date: Mon, 19 Nov 2007 22:08:07 -0800 (PST)
Message-ID: <20071119.220807.216500794.davem@davemloft.net>
References: <11951338541351-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20071115.200032.115040183.davem@davemloft.net>
	<Pine.LNX.4.64.0711161306490.29353@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752662AbXKTGII convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 01:08:08 -0500
In-Reply-To: <Pine.LNX.4.64.0711161306490.29353@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 16 Nov 2007 15:44:40 +0200 (EET)

> Besides the log(n) search for which patches already exists, only O(ne=
w=20
> information) scan start..end range would be necessary. Or had you=20
> something else in mind (I'm not that sure what the "ideas", in plural=
,
> were :-))? ...I haven't forgotten the RB-tree things either (and I'm
> well aware of the limited scope of things this patch addresses).

Since you brought it up, can you respin the RB-tree patches?  Let's
just put them into net-2.6.25 and let them cook in there for a long
time.

If they prove to be too expensive in the no-loss case we can do
something like lazy tree creation or simply improving the
insert/delete implmentation.

I think it's important to put RB-tree in because a lot of the ideas
we are discussing have different implications if we go one way or
the other so we should commit to something now in order to focus
our efforts better.
