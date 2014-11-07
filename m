From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: Fix to enable UDP checksums on
 interface
Date: Thu, 06 Nov 2014 22:00:15 -0500 (EST)
Message-ID: <20141106.220015.627911044833896569.davem@davemloft.net>
References: <1415325961-23053-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbaKGDAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 22:00:20 -0500
In-Reply-To: <1415325961-23053-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu,  6 Nov 2014 18:06:01 -0800

> Add definition to vxlan nla_policy for UDP checksum. This is necessary
> to enable UDP checksums on VXLAN.
> 
> In some instances, enabling UDP checksums can improve performance on
> receive for devices that return legacy checksum-unnecessary for UDP/IP.
> Also, UDP checksum provides some protection against VNI corruption.
> 
> Testing:
 ...
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
