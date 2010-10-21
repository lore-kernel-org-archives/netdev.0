From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: synchronize bind() with RTM_NEWADDR notifications
Date: Thu, 21 Oct 2010 03:50:04 -0700 (PDT)
Message-ID: <20101021.035004.212683583.davem@davemloft.net>
References: <1287655930-16879-1-git-send-email-timo.teras@iki.fi>
	<1287656753.6871.46.camel@edumazet-laptop>
	<4CC018E1.3000906@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44300
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755081Ab0JUKtl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 06:49:41 -0400
In-Reply-To: <4CC018E1.3000906@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 21 Oct 2010 13:41:37 +0300

> Is inet_bind() called from non-userland context? If yes, then this is=
 a
> bad idea. Otherwise I don't think it's that hot path...

It is.
