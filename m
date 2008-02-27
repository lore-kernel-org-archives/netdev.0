From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH]: TCP + SACK + skb processing latency
Date: Tue, 26 Feb 2008 22:45:55 -0800 (PST)
Message-ID: <20080226.224555.239440389.davem@davemloft.net>
References: <Pine.LNX.4.64.0802011756140.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36176
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752838AbYB0Gpz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 01:45:55 -0500
In-Reply-To: <Pine.LNX.4.64.0802011756140.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 1 Feb 2008 18:18:02 +0200 (EET)

Interesting idea... it is like a baby step towards a more efficient
write queue data management facility :-)

> I'd appreciate if somebody with more knowledge about skb internals co=
uld=20
> take a look at the relevant parts (mainly skb_shift) and confirm that=
=20
> doing all this I'm trying to do is allowed :-).

It looks good.  You never have to worry about skb's in the write queue
having headers, ever.  They only contain data.


