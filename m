From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netlink event for network device statistics
Date: Tue, 01 Dec 2009 12:28:59 +0100
Message-ID: <4B14FDFB.7060600@trash.net>
References: <1259535397.4421.3.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41185 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbZLAL24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 06:28:56 -0500
In-Reply-To: <1259535397.4421.3.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann wrote:
> Hi everyone,
> 
> so I was playing with monitoring network device statistics and storing
> them over a period of time. While netlink and ethtool provides all the
> network packet statistics, I have a problem with devices that are
> actually hotplug. Especially 3G cards that get taken off the bus via
> RFKILL and external dongles that can be unplugged at any time.
> 
> So I was thinking that before we send the DELLINK netlink event for that
> interface, we should send the latest statistic details via netlink. Is
> that a good idea or is there another way to get up-to-date statistics
> without polling for them?

Don't we already include them in the DELLINK message? rtnl_fill_ifinfo()
unconditionally includes the statistics.
