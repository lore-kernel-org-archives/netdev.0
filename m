From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Thu, 02 Oct 2008 17:41:34 -0700
Message-ID: <m11vyyv7b5.fsf@frodo.ebiederm.org>
References: <20080929175412.866679567@theryb.frec.bull.fr>
	<20080929175421.722037051@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59664 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902AbYJCApu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 20:45:50 -0400
In-Reply-To: <20080929175421.722037051@theryb.frec.bull.fr> (Benjamin Thery's
	message of "Mon, 29 Sep 2008 19:54:22 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery <benjamin.thery@bull.net> writes:

> This patch proposes to replace the rtnl_unlock() call in 
> linkwatch_event() by __rtnl_unlock(). The difference between the two
> routines being that __rtnl_unlock() will not call netdev_run_todo()
> after it unlocks rtnl_mutex.
>
> This is to fix a "deadlock" we observed when unregistering a net device.

Thanks for tracking this I just started seeing this a few days ago, and
before I reach the point of tracking it down you are in the process
of fixing it ;)

Eric
