From: David Miller <davem@davemloft.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Mon, 25 Feb 2008 12:12:56 -0800 (PST)
Message-ID: <20080225.121256.266297266.davem@davemloft.net>
References: <1203933228.13162.58.camel@johannes.berg>
	<20080225.115220.02432174.davem@davemloft.net>
	<1203969403.13162.147.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, joe@perches.com, harvey.harrison@gmail.com,
	netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39743
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755623AbYBYUMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 15:12:12 -0500
In-Reply-To: <1203969403.13162.147.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 25 Feb 2008 20:56:43 +0100

> 
> On Mon, 2008-02-25 at 11:52 -0800, David Miller wrote:
> > From: Johannes Berg <johannes@sipsolutions.net>
> > Date: Mon, 25 Feb 2008 10:53:48 +0100
> > 
> > > Maybe we should just add a new printf modifier like %M for MAC
> > > addresses? Then we could use sprintf, snprintf, printk and whatever we
> > > please without any of the macro stuff...
> > 
> > But GCC has no idea what the heck it is and will warn.
> 
> No, I actually wondered about that too and finally just tried, it simply
> ignores it when doing the printf warnings.

Ok, so it simply can't validate the thing.
