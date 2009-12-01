From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Netlink event for network device statistics
Date: Tue, 01 Dec 2009 14:36:14 +0100
Message-ID: <1259674574.4421.15.camel@violet>
References: <1259535397.4421.3.camel@violet>  <4B14FDFB.7060600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:39018 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbZLANgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 08:36:35 -0500
In-Reply-To: <4B14FDFB.7060600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

> > so I was playing with monitoring network device statistics and storing
> > them over a period of time. While netlink and ethtool provides all the
> > network packet statistics, I have a problem with devices that are
> > actually hotplug. Especially 3G cards that get taken off the bus via
> > RFKILL and external dongles that can be unplugged at any time.
> > 
> > So I was thinking that before we send the DELLINK netlink event for that
> > interface, we should send the latest statistic details via netlink. Is
> > that a good idea or is there another way to get up-to-date statistics
> > without polling for them?
> 
> Don't we already include them in the DELLINK message? rtnl_fill_ifinfo()
> unconditionally includes the statistics.

you are correct. We already have the IFLA_STATS in DELLINK. I got
confused with ip monitor not decoding these and assumed they were not
included at all.

Regards

Marcel


