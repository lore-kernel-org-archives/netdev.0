From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 11:58:55 -0700 (PDT)
Message-ID: <20080505.115855.137964071.davem@davemloft.net>
References: <1210000923.8245.26.camel@johannes.berg>
	<1ba2fa240805051015t7dfd3bd2nf7bc2fc1ab9799ca@mail.gmail.com>
	<1210010254.4181.4.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasw@gmail.com, linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759219AbYEES64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 14:58:56 -0400
In-Reply-To: <1210010254.4181.4.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 05 May 2008 19:57:34 +0200

> NETIF_F_FRAGLIST I haven't understood, but it seems to apply mostly for
> IP fragmentation?

That's right.  It's for cards that can do IP fragmentation in
hardware.
