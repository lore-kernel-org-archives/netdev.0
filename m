From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: bcm43xx driver unstable behaviour (and linux wireless is junk
	btw)
Date: Mon, 25 Sep 2006 19:58:01 +1000
Message-ID: <1159178281.13140.5.camel@localhost.localdomain>
References: <1159065798.5924.8.camel@localhost.localdomain>
	 <4515FF5D.4080602@gentoo.org>
	 <1159078683.5924.16.camel@localhost.localdomain>
	 <1159174960.4509.13.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, Bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:14551 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1750880AbWIYJ6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 05:58:25 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1159174960.4509.13.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> yes. Many locking issues in d80211 to still sort out. Basically, there
> are next to no useful locks in it and most data structures are not
> protected at all.

Doh ! Scary... locking is hard ... if the stuff was written without
locking in mind in the first place, it might end up being a nightmare...

Ben.


