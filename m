From: Volkan YAZICI <volkan.yazici@gmail.com>
Subject: How To Temporarily Suspend Network Traffic
Date: Tue, 01 Feb 2011 16:28:46 +0200
Message-ID: <87d3nbakwx.fsf@alamut.ozu.edu.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54081 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756888Ab1BAO1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 09:27:13 -0500
Received: by fxm20 with SMTP id 20so6856099fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Feb 2011 06:27:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I want to temporarily suspend the network traffic on a particular
interface -- if possible, in microsecond granularity. For this purpose,
ifup/ifdown ioctl() calls doesn't work. That is, for wireless
interfaces, connection isn't get recovered; for wired interfaces, it
takes at least 2 seconds to recover. I tried using tc, but it doesn't
accept "rate 0" parameter. Neither "iwconfig wlan0 rate 0" has any
effect. (Moreover, in iwconfig manual it is told that values below 1000
are card specific and are usually an index in the bit-rate list.) Do you
have any suggestions? Can you recommend me to check any code piece in
the kernel or some other tool?


Regards.
