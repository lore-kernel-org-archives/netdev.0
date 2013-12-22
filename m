From: Amir Vadai <amirv@mellanox.com>
Subject: Definition of the term rx/tx/combined channel
Date: Sun, 22 Dec 2013 17:06:15 +0200
Message-ID: <52B6FFE7.6080906@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eugenia Emantayev <eugenia@mellanox.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:48827 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753424Ab3LVPIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 10:08:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

I'm trying to understand the exact definition of the term channel.

According to ethtool: A channel is an IRQ and the set of queues that can
trigger that IRQ.

In our driver (Mellanox's Connect-X), we have an IRQ's, rx rings and tx
rings.

Usually we have one IRQ per rx ring, but if system resources are
limited, those numbers could be different.
tx rings are sharing the same IRQ's assigned by rx rings (for
completions), but many tx rings could share the same IRQ.

Is the rx channels == number of rx rings, and same for tx?
How is this related to the number of IRQ's?
Should we show other IRQ's we use for async events from the HW, as 'other'?

Thanks,
Amir
