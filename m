From: Marcel Holtmann <marcel@holtmann.org>
Subject: Netlink event for network device statistics
Date: Sun, 29 Nov 2009 23:56:37 +0100
Message-ID: <1259535397.4421.3.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:48226 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbZK2W4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 17:56:53 -0500
Received: from [192.168.1.42] (p5487D10F.dip.t-dialin.net [84.135.209.15])
	by mail.holtmann.org (Postfix) with ESMTP id 1CD078B4DA
	for <netdev@vger.kernel.org>; Sun, 29 Nov 2009 23:57:00 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

so I was playing with monitoring network device statistics and storing
them over a period of time. While netlink and ethtool provides all the
network packet statistics, I have a problem with devices that are
actually hotplug. Especially 3G cards that get taken off the bus via
RFKILL and external dongles that can be unplugged at any time.

So I was thinking that before we send the DELLINK netlink event for that
interface, we should send the latest statistic details via netlink. Is
that a good idea or is there another way to get up-to-date statistics
without polling for them?

Regards

Marcel


