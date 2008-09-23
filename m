From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: tcp: Fix queue traversal in tcp_use_frto().
Date: Tue, 23 Sep 2008 15:00:34 -0700 (PDT)
Message-ID: <20080923.150034.74273991.davem@davemloft.net>
References: <20080923.025542.193703353.davem@davemloft.net>
	<Pine.LNX.4.64.0809232214320.14360@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56331
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751178AbYIWWAq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 18:00:46 -0400
In-Reply-To: <Pine.LNX.4.64.0809232214320.14360@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 23 Sep 2008 22:18:33 +0300 (EEST)

> For the record (as you probably know it already), this wasn't actuall=
y
> a real bug though it hits your BUG_ON since tcp_for_write_queue_from =
exits
> immediately, no garbage gets dereferenced.

Yes, that is correct.

It is actually disappointing for me, I thought maybe it would catch
a real bug somewhere :-)
