From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next 0/4] tun: Some bits required for tun's checkpoint-restore
Date: Mon, 19 Aug 2013 19:09:09 +0400
Message-ID: <52123515.3060507@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:53339 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab3HSPJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 11:09:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After taking a closer look on tun checkpoint-restore I've found several
issues with the tun's API that make it impossible to dump and restore
the state of tun device and attached tun-files.

The proposed API changes are all about extending the existing ioctl-based
stuff. Patches fit today's net-next.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
