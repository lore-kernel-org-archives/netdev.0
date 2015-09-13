From: Nathan Neulinger <nneul@neulinger.org>
Subject: Any way to configure a vlan interface to grab ONLY untagged frames?
Date: Sun, 13 Sep 2015 11:49:00 -0500
Message-ID: <55F5A8FC.1020707@neulinger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36404 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbbIMQtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Sep 2015 12:49:03 -0400
Received: by oibi136 with SMTP id i136so65982004oib.3
        for <netdev@vger.kernel.org>; Sun, 13 Sep 2015 09:49:01 -0700 (PDT)
Received: from skyhawk.home.neulinger.org (67-43-241-123.fidnet.com. [67.43.241.123])
        by smtp.gmail.com with ESMTPSA id jp2sm4598619oeb.4.2015.09.13.09.49.00
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Sep 2015 09:49:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems like running 'vconfig add IFACE 0' and using IFACE.0 would do this, but it doesn't actually seem to work that way.

If I capture on IFACE directly, I'd expect to get all traffic, including the tagged frames (with the tag intact). 
Looking to be able to bridge/capture/etc. and specifically only receive the untagged frames that haven't already been 
pulled out into a vlan specific interface.

Is there any way to accomplish this without using ebtables or other similar hacks?

-- Nathan

------------------------------------------------------------
Nathan Neulinger                       nneul@neulinger.org
Neulinger Consulting                   (573) 612-1412
