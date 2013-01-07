From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [BUG] via_rhine stops making new tcp connections.
Date: Mon, 7 Jan 2013 07:55:40 -0800
Message-ID: <20130107075540.60d6d7fb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49146 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753064Ab3AGP5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 10:57:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please look at this bug report from davidwhodgins@gmail.com
 https://bugzilla.kernel.org/show_bug.cgi?id=52151


As shown in the pcap file
https://bugs.mageia.org/attachment.cgi?id=3304
after a period of time ranging from hours to weeks,
the driver starts replying to syn,ack messages with reset,
instead of ack messages.

Rebooting corrects the problem, as shown by the pcap file
https://bugs.mageia.org/attachment.cgi?id=3305
