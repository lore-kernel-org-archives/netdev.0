From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipconfig: send Client-identifier in DHCP
 requests
Date: Sun, 18 Oct 2015 19:24:21 -0700 (PDT)
Message-ID: <20151018.192421.244456964087793743.davem@davemloft.net>
References: <1444899276-21228-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbbJSCIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 22:08:04 -0400
In-Reply-To: <1444899276-21228-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 15 Oct 2015 16:54:36 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> A dhcp server may provide parameters to a client from a pool of IP
> addresses and using a shared rootfs, or provide a specific set of
> parameters for a specific client, usually using the MAC address to
> identify each client individually. The dhcp protocol also specifies
> a client-id field which can be used to determine the correct
> parameters to supply when no MAC address is available. There is
> currently no way to tell the kernel to supply a specific client-id,
> only the userspace dhcp clients support this feature, but this can
> not be used when the network is needed before userspace is available
> such as when the root filesystem is on NFS.
> 
> This patch is to be able to do something like "ip=dhcp,client_id_type,
> client_id_value", as a kernel parameter to enable the kernel to
> identify itself to the server.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Looks good, applied, thanks.
