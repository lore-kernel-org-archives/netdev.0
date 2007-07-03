From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] [TCP]: Tighten tcp_sock's belt, drop left_out
Date: Mon, 02 Jul 2007 22:02:27 -0700 (PDT)
Message-ID: <20070702.220227.15591645.davem@davemloft.net>
References: <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20070531.014241.28790645.davem@davemloft.net>
	<Pine.LNX.4.64.0705311846390.14736@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42289
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751264AbXGCFCI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 01:02:08 -0400
In-Reply-To: <Pine.LNX.4.64.0705311846390.14736@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 31 May 2007 19:31:21 +0300 (EEST)

> (i.e, how does it show up in oops if tcp_verify_left_out looks like t=
his):
>=20
> #define tcp_verify_left_out(tp) BUG_ON(...)
>=20
> ...does it still point to the tcp.h line xxxx then or to the
> tcp_sync_left_out(tp) @ line yyyy in tcp_input.c? ...I'll test that
> later on by myself in case you don't know the answer.

Yes a define would make the BUG appear in the function it gets
used in.

Depending upon the configuration and the implementation of BUG()
the same might happen for inline functions too.  For example, if
the BUG() is configured in non-verbose mode and is implemented using
a trap instruction or __builtin_trap().  But you cannot depend
upon this universally of course.
