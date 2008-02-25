From: David Miller <davem@davemloft.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Mon, 25 Feb 2008 11:52:20 -0800 (PST)
Message-ID: <20080225.115220.02432174.davem@davemloft.net>
References: <47BDBC23.5080007@trash.net>
	<20080223.200202.255773165.davem@davemloft.net>
	<1203933228.13162.58.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, joe@perches.com, harvey.harrison@gmail.com,
	netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43286
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755517AbYBYTvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 14:51:37 -0500
In-Reply-To: <1203933228.13162.58.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 25 Feb 2008 10:53:48 +0100

> Maybe we should just add a new printf modifier like %M for MAC
> addresses? Then we could use sprintf, snprintf, printk and whatever we
> please without any of the macro stuff...

But GCC has no idea what the heck it is and will warn.
