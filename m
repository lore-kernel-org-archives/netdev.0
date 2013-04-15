From: Tomas Agartz <tlund@nxs.se>
Subject: No longer able to add iptunnel interface to bridge?
Date: Mon, 15 Apr 2013 18:14:32 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.1304151757340.20041@envy.nxs.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from envy.nxs.se ([212.247.200.182]:41787 "EHLO envy.nxs.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754583Ab3DOQOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 12:14:37 -0400
Received: from localhost (localhost [127.0.0.1])
	by envy.nxs.se (Postfix) with ESMTP id DCC0D2BEBD
	for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 18:14:32 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After rebooting my router/firewall (Debian Wheezy with debian 3.2.41-2 
kernel), I am no longer able to add an iptunnel to a bridge interface.

The iptunnel is configured like this:

iptunnel add TUNNEL mode ipip remote x.x.x.x local y.y.y.y ttl 32
ifconfig TUNNEL z.z.z.z netmask 255.255.255.254 up

and this is what strace shows when I try to do "brctl addif test TUNNEL":

ioctl(3, SIOCBRADDIF, 0x7fffafba64c0)   = -1 EINVAL (Invalid argument)
ioctl(3, SIOCDEVPRIVATE, 0x7fffafba64c0) = -1 EINVAL (Invalid argument)

I have no idea if I might have changed something in userspace by misstake, 
or if there has been a change in the kernel since last reboot. The same 
machine has a different bridge with an L2TPv3 tunnel added, this works 
fine.

I understand that the info here is not much to go on, but I am unsure what 
else to attach. Plese ask for further info and I shall provide it!

Best regards,
Tomas
