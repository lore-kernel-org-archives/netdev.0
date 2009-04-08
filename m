From: Rick Jones <rick.jones2@hp.com>
Subject: Re: dhcp-based netboot over jumbo-frame network?
Date: Wed, 08 Apr 2009 12:15:46 -0700
Message-ID: <49DCF7E2.2060304@hp.com>
References: <49DCE470.9060109@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Network Development list <netdev@vger.kernel.org>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:38102 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbZDHTPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 15:15:51 -0400
In-Reply-To: <49DCE470.9060109@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:
> 
> Hi all,
> 
> We have an existing system that loads a bare kernel using tftp, then 
> mounts a rootfs via NFS.  The wrinkle is that this is on a jumbo-frame 
> enabled network, so somehow the MTU needs to be set before mounting the 
> rootfs.

Why?  Is the NFS mount not TCP?  If it is TCP, then the TCP MSS exchange will 
provide you cover as it will (should) cause TCP in the NFS server to segment to 
the MSS option your system with the then-smaller MTU sends.

I would think that only if the NFS mount is UDP that you would have a problem 
with the system initially booting with a small MTU.

> In a previous version we patched ipconfig.c to support the DHCP option 
> to specify the MTU value, but I'm wondering about the "proper" way to do 
> this on current kernels.

Was the change submitted to upstream and rejected?

rick jones
