From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/3] [NET-NEXT]: Add DCB netlink interface definition
Date: Wed, 28 May 2008 11:41:40 +0200
Message-ID: <20080528094140.GD20815@postel.suug.ch>
References: <20080527141339.12851.98781.stgit@localhost.localdomain> <20080527141346.12851.2280.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, davem@davemloft.net, netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:60562 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753846AbYE1JlX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 05:41:23 -0400
Content-Disposition: inline
In-Reply-To: <20080527141346.12851.2280.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com> 2008-05-27 07:13
> This patch adds the netlink interface definition for Data Center Bridging.
> This technology uses 802.1Qaz and 801.1Qbb for extending ethernet to
> converge different traffic types on a single link.  E.g. Fibre Channel
> over Ethernet and regular LAN traffic.  The goal is to use priority flow
> control to pause individual flows at the MAC/network level, without
> impacting other network flows.

Is there a specific reason why you used a separate generic netlink
interface instead of embedding this into the regular link message
via either IFLA_DCB or by using the info API?
