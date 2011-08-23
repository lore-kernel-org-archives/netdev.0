From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: IPv6 multicast snooping behaviour on 2.6.39-rc2 and later
Date: Tue, 23 Aug 2011 17:41:46 +0900
Message-ID: <4E5367CA.3090005@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:44425 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754576Ab1HWIrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 04:47:14 -0400
Received: from [202.249.25.135] (unknown [202.249.25.135])
	by mail.sfc.wide.ad.jp (Postfix) with ESMTPSA id 18F8E27809B
	for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 17:41:46 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

    Sorry for cross-posting. I have a testbed setup on my VM environment that needs to use MLDv2 report message. My PIM router which is connected to a port on the bridge relies upon MLDv2 message to work. However, the setup failed to work after 2.6.39-rc2 or later. MLDv2 won't be forwarded to any slave ports bound to the bridge interface. Specifically, I track the cause down to this commit id:

      ff9a57a62afbbe2d0f3a09af321f1fd7645f38a5

    However, as soon as I disable multicast snooping on sysfs, MLDv2 message can be forwarded again.

    I am not knowledgeable on the subject of multicast snooping, but is this right behaviour for multicast snooping? IPv4 doesn't seem to suffer the same fate though, IGMP can be forwarded even if multicast_snooping is enabled. Thank you in advance.


Regards,
Ang Way Chuang


