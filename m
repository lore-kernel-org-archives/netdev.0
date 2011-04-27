From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/1] bna: Generic Netlink Interface to collect FW
 trace
Date: Tue, 26 Apr 2011 19:17:07 -0700 (PDT)
Message-ID: <20110426.191707.71110914.davem@davemloft.net>
References: <1303869117-780-1-git-send-email-rmody@brocade.com>
	<20110426185917.3d033636@nehalam>
	<BANLkTinUsJ2foWKBVb_9nVFA2V_vKb11rA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, rmody@brocade.com, netdev@vger.kernel.org,
	huangj@brocade.com, amathur@brocade.com, ddutt@brocade.com
To: debdut@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43762
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756082Ab1D0CRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 22:17:41 -0400
In-Reply-To: <BANLkTinUsJ2foWKBVb_9nVFA2V_vKb11rA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Debashis Dutt <debdut@gmail.com>
Date: Tue, 26 Apr 2011 19:16:29 -0700

> However, since the generic netlink is a more generic interface, we could use
> this infrastructure in the driver for commands which are not part of
> other standard tools.

You aren't the only device in the world that might want to provide
a facility to fetch firmware traces.

This isn't really a niche thing specific to your device at all.
