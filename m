From: David Miller <davem@davemloft.net>
Subject: Re: Killing sk->sk_callback_lock
Date: Wed, 18 Jun 2008 14:56:52 -0700 (PDT)
Message-ID: <20080618.145652.193031154.davem@davemloft.net>
References: <4857F579020000B30004963C@lucius.provo.novell.com>
	<4858E838020000C7000397CF@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, GHaskins@novell.com,
	chuck.lever@oracle.com, netdev@vger.kernel.org
To: pmullaney@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50859
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753909AbYFRV4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 17:56:52 -0400
In-Reply-To: <4858E838020000C7000397CF@lucius.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Patrick Mullaney" <pmullaney@novell.com>
Date: Wed, 18 Jun 2008 10:49:28 -0600

> I will give it a shot - I still have reservations about changing the
> socket structures - at first glance, it seems like sock and socket will
> have to change.

If you work against net-next-2.6 everything setting sk->sk_sleep is
compartmentalized into a small number of code locations.  So such work
ought to be trivial.
