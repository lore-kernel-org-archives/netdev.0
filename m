From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/12]: wext: Emit event stream entries correctly when
 compat.
Date: Tue, 03 Jun 2008 13:57:28 -0700 (PDT)
Message-ID: <20080603.135728.103448928.davem@davemloft.net>
References: <20080603.132856.202640855.davem@davemloft.net>
	<1212526129.14371.5.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, linville@tuxdriver.com,
	mokuno@sm.sony.co.jp, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751682AbYFCU53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 16:57:29 -0400
In-Reply-To: <1212526129.14371.5.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 03 Jun 2008 22:48:49 +0200

> Did you miss drivers/net/ps3_gelic_wireless.c?

Likely yes, I guess that won't get hit with an allmodconfig
build on sparc64 :(

It would be really nice if we had some more compat layers
so that the ps3 bus probing layer just nopped out but you
could at least build test drivers on other platforms.
