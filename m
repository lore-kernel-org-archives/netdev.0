From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix TSO FACK loss marking in tcp_mark_head_lost
Date: Mon, 27 Sep 2010 14:56:41 -0700 (PDT)
Message-ID: <20100927.145641.55868180.davem@davemloft.net>
References: <alpine.DEB.2.00.1009271520560.26447@wel-95.cs.helsinki.fi>
	<20100927.111114.124003889.davem@davemloft.net>
	<alpine.DEB.2.00.1009272155030.15680@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ycheng@google.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60705
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759288Ab0I0V4V convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 17:56:21 -0400
In-Reply-To: <alpine.DEB.2.00.1009272155030.15680@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 27 Sep 2010 22:20:57 +0300 (EEST)

> I disagree now with myself btw, it's not just "a policy decision" as =
we=20
> do not retransmit some segments at all before RTO in some scenarios.

Ok, thanks for explaining all of this.

I've applied Yuchung's patch to net-2.6, thanks everyone!
