From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next 0/4] tun: Some bits required for tun's checkpoint-restore
 (v2)
Date: Wed, 21 Aug 2013 14:31:11 +0400
Message-ID: <521496EF.8090909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:49956 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3HUKbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 06:31:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After taking a closer look on tun checkpoint-restore I've found several
issues with the tun's API that make it impossible to dump and restore
the state of tun device and attached tun-files.

The proposed API changes are all about extending the existing ioctl-based
stuff. Patches fit today's net-next.

This v2 has David's comments about patch #1 fixed. All the rest is the same.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
