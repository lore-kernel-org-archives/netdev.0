From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET 2.6.26]: Add per-connection option to set max TSO
 frame size
Date: Fri, 21 Mar 2008 03:45:11 -0700 (PDT)
Message-ID: <20080321.034511.227507227.davem@davemloft.net>
References: <20080305173510.5681.17426.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35518
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753469AbYCUKpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 06:45:00 -0400
In-Reply-To: <20080305173510.5681.17426.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Date: Wed, 05 Mar 2008 09:35:10 -0800

> This patch adds the ability for device drivers to control the size of the
> TSO frames being sent to them, per TCP connection.  By setting the
> netdevice's gso_max_size value, the socket layer will set the GSO
> frame size based on that value.  This will propogate into the TCP layer,
> and send TSO's of that size to the hardware.

Applied to net-2.6.26, thanks.

Sorry I didn't get to this sooner as I've been away in Japan most of
this month and have been only applying the most important fixes and
the most trivial feature patches.
