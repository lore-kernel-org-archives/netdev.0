From: Sebastian Fett <db_extern@gmx.de>
Subject: ARP response with link local IP, why not broadcast
Date: Tue, 21 Jul 2015 16:38:16 +0200
Message-ID: <55AE5958.3020009@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:64023 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754598AbbGUOiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2015 10:38:20 -0400
Received: from [192.168.11.112] ([94.186.167.49]) by mail.gmx.com (mrgmx001)
 with ESMTPSA (Nemesis) id 0Lt2BW-1YoVW71sTK-012WbL for
 <netdev@vger.kernel.org>; Tue, 21 Jul 2015 16:38:17 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

According to RFC3927 every ARP packet (reply and request) should be sent 
as link layer broadcast as long as the sender IP is a link local 
address. (see chapter 2.5).
That functionality would help me a lot with a use case I have with our 
application.

But it is not implemented in the kernel that way.
Does anyone know why?

Regards,
Sebastian
