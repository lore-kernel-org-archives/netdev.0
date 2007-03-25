From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCHv5 1/5] [TCP]: Add highest_sack seqno, points to
 globally highest SACK
Date: Sat, 24 Mar 2007 21:04:28 -0700 (PDT)
Message-ID: <20070324.210428.78711276.davem@davemloft.net>
References: <11740704663475-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11740704662337-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56647
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932687AbXCYEE3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2007 00:04:29 -0400
In-Reply-To: <11740704662337-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 16 Mar 2007 20:41:02 +0200

> It is guaranteed to be valid only when !tp->sacked_out. In most
> cases this seqno is available in the last ACK but there is no
> guarantee for that. The new fast recovery loss marking algorithm
> needs this as entry point.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Patch applied, thanks Ilpo.

It's a shame we keep around multiple values which represent very
related values.  For example, this new seqno could be computed
using "fackets_out" if we knew also how many holes there were.
