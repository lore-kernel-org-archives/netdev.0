From: "J.Hwan Kim" <frog1120@gmail.com>
Subject: Unicast hash for IXGBEVF driver
Date: Sat, 27 Aug 2011 16:23:21 +0900
Message-ID: <4E589B69.7020305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:49035 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab1H0HXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2011 03:23:25 -0400
Received: by pzk37 with SMTP id 37so5448722pzk.1
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2011 00:23:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, everyone

How can I distribute the packets according to destination MAC address
into multi-virtual fucntion queue?
Now, my setting is that all bit of PFUTA are '1' and ROPE bit is 1,
so all mac packet is duplicated to all VF queue.
I cannot understand the meaning of bits of PFUTA and the relation
with mac address.
I want to distribute the received packets to RX queues respectively,
not duplicated.


Thanks in advance.

Best Regards,
J.Hwan Kim
