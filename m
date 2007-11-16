From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Thu, 15 Nov 2007 18:54:03 -0800 (PST)
Message-ID: <20071115.185403.138420969.davem@davemloft.net>
References: <473D0482.4050705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53604
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752891AbXKPCyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 21:54:04 -0500
In-Reply-To: <473D0482.4050705@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 16 Nov 2007 10:46:26 +0800

> The current kernel doesn't verify the udp checksum if user doesn't set a
> socket filter.It's fine for LAN. But for WAN, it's not a good option.
> Shall we fix it? Below is the patch to make udp checksum be always 
> available.
> 
> [IPV4] UDP: Always checksum even if without socket filter
> Make udp checksum be always available even if without socket filter.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

It checks the checksum in udp_recvmsg() and udp_poll().

Please do not fix bugs via code inspection without writing
test programs to validate whether there is really a "bug"
here or not.
