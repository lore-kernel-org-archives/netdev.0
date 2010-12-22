From: Alkis Georgopoulos <alkisg@gmail.com>
Subject: Bypass flow control problems
Date: Wed, 22 Dec 2010 19:51:31 +0200
Message-ID: <1293040291.1777.36.camel@alkis>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:56603 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919Ab0LVRvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 12:51:35 -0500
Received: by bwz16 with SMTP id 16so5985347bwz.4
        for <netdev@vger.kernel.org>; Wed, 22 Dec 2010 09:51:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm an IT teacher/LTSP developer. In LTSP, thin clients are netbooted
from a server and receive a lot of X and remote disk traffic from it.

Many installations have a gigabit NIC on the server, an unmanaged
gigabit switch, and 100 Mbps NICs on the clients.

With flow control on, the server is limited to sending 100 Mbps to all
the clients. So with 10 thin clients the server can concurrently send
only 10 Mbps to each one of them.

On NICs that support it, we turn flow control off and the server can
properly send 100 Mbps to each client, i.e. 1 Gbps to 10 clients.

 * Is there any way to bypass that problem on NICs that do not support
   turning off flow control, like e.g. realteks?
   I.e. when a client sends a pause signal to the server, instead of the
   server pausing, to continue sending data to another client?
   Or even to limit the amound of data the server sends to each client,
   so that the clients never have to send pause signals?

 * I really don't understand why flow control is enabled by default on
   NICs and switches. In which case does it help? As far as I
   understand, all it does is ruin gigabit => 100 Mbps connections...

 * As a side note, since rtl8169 is a very common chipset, is there a
   way to disable flow control for that specific NIC?

This problem affects thousands of LTSP installations, we'd much
appreciate your knowledge and feedback on it.

Thank you,
Alkis Georgopoulos

