From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: [sky2, solved] transmit timeouts and firmware update...
Date: Mon, 25 Aug 2008 15:42:58 +0100
Message-ID: <6278d2220808250742r4a2b377al13a516fa0c6b53a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Linux Netdev" <netdev@vger.kernel.org>,
	"Linux Networking" <linux-net@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:37852 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814AbYHYOm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 10:42:59 -0400
Received: by py-out-1112.google.com with SMTP id p76so1065132pyb.10
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 07:42:59 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I (and a lot of other users) have been experiencing the frequent sky2
transmit timeout problem [1] (on 88E8053/Yukon2 EC gig hardware); this
is a result of the embedded NIC controller locking up, and I've found
that updating the firmware addresses this issue. I'm still seeing a
previous and different issue [2] from time to time though (silicon
bug?).

Marvell shipping broken firmware is completely unpublicised or
acknowledged, however updated firmware is available through your
motherboard vendor, so all hope it not lost after all...

My 8053/EC is using firmware 2.2 (previously 1.9) - you can check in
DOS with 'yukondg.exe' from
http://www.marvell.com/drivers/files/yukondg_v6.53.4.3.zip .

Thanks,
  Daniel

--- [1]

NETDEV WATCHDOG: eth0 (sky2): transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 20 .. 491 report=20 done=20
...

--- [2]

sky2 eth0: hung mac 1:119 fifo 7 (90:163)
sky2 eth0: receiver hang detected
sky2 eth0: disabling interface
sky2 eth0: enabling interface
-- 
Daniel J Blueman
