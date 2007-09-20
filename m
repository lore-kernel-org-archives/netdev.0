From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9] [TCP] FRTO: Improve interoperability with other
 undo_marker users
Date: Thu, 20 Sep 2007 11:35:04 -0700 (PDT)
Message-ID: <20070920.113504.108809397.davem@davemloft.net>
References: <1190290672770-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11902906721671-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11902906723159-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756766AbXITSfE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 14:35:04 -0400
In-Reply-To: <11902906723159-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 20 Sep 2007 15:17:49 +0300

> Basically this change enables it, previously other undo_marker
> users were left with nothing. Reverse undo_marker logic
> completely to get it set right in CA_Loss. On the other hand,
> when spurious RTO is detected, clear it. Clearing might be too
> heavy for some scenarios but seems safe enough starting point
> for now and shouldn't have much effect except in majority of
> cases (if in any).
>=20
> By adding a new FLAG_ we avoid looping through write_queue when
> RTO occurs.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.  Thanks for following up on all of this stuff to
get FRTO in shape.
