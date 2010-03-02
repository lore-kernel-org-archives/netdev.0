From: Franco Fichtner <franco@lastsummer.de>
Subject: e1000e: reset of tx_queue_len
Date: Tue, 02 Mar 2010 18:44:30 +0100
Message-ID: <4B8D4E7E.2000805@lastsummer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:40569 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691Ab0CBRob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 12:44:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

while working on a new server, I noticed that tx_queue_len is reset
to the default of 1000 while ADDRCONF(NETDEV_CHANGE).
This happens with 2.6.30.8, but I could not see any obvious
differences to the current state of e1000e, while trying to find the
problem in the code.

The interface has been configured including a customized qlen
via /etc/network/interfaces. The ports are not connected at startup
so obviously the Kernel reports

ADDRCONF(NETDEV_UP): eth2: link is not ready

while ifconfig properly displays the customized qlen.

When plugging the server tx_queue_len is reset to 1000.

Any help is appreciated. Thanks.


Franco
