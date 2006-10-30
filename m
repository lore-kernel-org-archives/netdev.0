From: Dmitry Mishin <dim@openvz.org>
Subject: Bridge & it's MAC address question
Date: Mon, 30 Oct 2006 15:27:14 +0300
Message-ID: <200610301527.15018.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@osdl.org, devel@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:62564 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1751467AbWJ3M10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 07:27:26 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Could somebody explain, why bridge uses minimal MAC of the attached devices?
It makes this address instable, variable during bridge life-cycle, which is 
not good for DHCP. For example, I want to attach multiple virtual devices to 
one physical. Then, I need to make sure that after each virtual device 
addition, bridge addr is not changed and still addr of the physical device.  
Why not to use MAC of the first attached device?

-- 
Thanks,
Dmitry.
