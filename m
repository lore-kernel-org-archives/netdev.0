From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Wed, 26 May 2010 00:33:07 -0700 (PDT)
Message-ID: <20100526.003307.112602435.davem@davemloft.net>
References: <20100525220858.1071f238@nehalam>
	<20100525.225236.226781050.davem@davemloft.net>
	<AANLkTinHGMtfw4Oydfgx0w7QLb-HyYSKdI-4smD-BEkq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, ycheng@google.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40452
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751042Ab0EZHc5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 03:32:57 -0400
In-Reply-To: <AANLkTinHGMtfw4Oydfgx0w7QLb-HyYSKdI-4smD-BEkq@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tom Herbert <therbert@google.com>
Date: Wed, 26 May 2010 00:06:35 -0700

> It's really not that simple.=A0 In the application with multiple
> connections, congestion may only affect some number of connections, s=
o
> more of the aggregate window may be preserved.=A0 This is an unfairne=
ss
> issue between 1 and N connection scenarios which is a real problem.

If this is true, then by all account your patch allows things to be
even worse.

Because now applications can still open up N connections, but with an
even larger initial CWND, with potentially exponential ramifications
on network congestion.

So yet another reason not to consider this feature seriously.  It's
not an application level attribute, it's a network path one.  Please
take it seriously because I really mean it.
