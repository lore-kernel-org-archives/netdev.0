From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Mon, 16 Aug 2010 20:53:16 -0700 (PDT)
Message-ID: <20100816.205316.226783098.davem@davemloft.net>
References: <E1Ogws4-0000NO-00.xeb-mail-ru@f238.mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60785
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755700Ab0HQDw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 23:52:58 -0400
In-Reply-To: <E1Ogws4-0000NO-00.xeb-mail-ru@f238.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please make the following changes:

1) Remove all of the "DEBUG" stuff.  First of all, you should never
   TAB indent "#ifdef DEBUG" CPP checks like that, it's awfully
   ugly and makes the code hard to read.  Next you can use
   pr_debug() or similar for things like this.

2) Combine all three patches into one single patch including everything.
   There is no need to split things up like this.

Thank you.
