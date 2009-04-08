From: "Chris Friesen" <cfriesen@nortel.com>
Subject: dhcp-based netboot over jumbo-frame network?
Date: Wed, 08 Apr 2009 11:52:48 -0600
Message-ID: <49DCE470.9060109@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org,
	Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:35641 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568AbZDHRxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 13:53:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

We have an existing system that loads a bare kernel using tftp, then 
mounts a rootfs via NFS.  The wrinkle is that this is on a jumbo-frame 
enabled network, so somehow the MTU needs to be set before mounting the 
rootfs.

In a previous version we patched ipconfig.c to support the DHCP option 
to specify the MTU value, but I'm wondering about the "proper" way to do 
this on current kernels.

I suppose the obvious answer would be initramfs.  The downsides to that 
solution are that it would increase the size of the kernel file, and we 
would need to change the existing build system.  In the face of a small 
patch to ipconfig, it's not a very attractive solution.

Looking forward to your responses.

Chris
