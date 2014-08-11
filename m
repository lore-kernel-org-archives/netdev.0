From: Marcel Holtmann <marcel@holtmann.org>
Subject: Missing support for PACKET_RECV_OUTPUT
Date: Sun, 10 Aug 2014 21:28:15 -0700
Message-ID: <49E58C04-6C48-421D-B718-CD4733C1766B@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54820 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaHKE1r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 00:27:47 -0400
Received: from [192.168.1.123] (S010620c9d099deff.vc.shawcable.net [24.84.124.211])
	by mail.holtmann.org (Postfix) with ESMTPSA id AEEFC8B30E
	for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 06:27:41 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I wonder why AF_PACKET does not support PACKET_RECV_OUTPUT socket option. I would find this useful when using AF_SOCKET to capture traffic on all interfaces, but only for a specific ETH_P_x specified in the socket call. Right now I have to manually enable promiscuous mode for every ifindex separately.

Is there any specific reason why this socket option has not been implemented? It is listed in linux/if_packet.h after all. Or is this just one of these things where nobody ended up implementing it?

Regards

Marcel
