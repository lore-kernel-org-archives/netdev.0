From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 01:31:07 -0800 (PST)
Message-ID: <20080117.013107.241902256.davem@davemloft.net>
References: <478F0DA5.2060401@iki.fi>
	<20080117.004900.58497170.davem@davemloft.net>
	<478F1DEA.5070903@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60722
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755452AbYAQJbH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 04:31:07 -0500
In-Reply-To: <478F1DEA.5070903@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Thu, 17 Jan 2008 11:20:42 +0200

> Where as the pfkey bug fix is non-intrusive and helps all
> legacy applications still using af_key by _fixing a bug in
> kernel_.

It's not a bug.  You're fixing a speed issue, not a crash
or a case where AF_KEY is providing incorrect data.

That is what I mean when I mean "life support", we fix crashes and
data corruption.  We don't make performance tweaks.
