From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.4.35.3] Fix the "InAddrErrors" increasing problem
Date: Sun, 21 Oct 2007 23:16:35 -0700 (PDT)
Message-ID: <20071021.231635.07638179.davem@davemloft.net>
References: <471C3E0B.2070602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: guijianfeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751162AbXJVGQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 02:16:21 -0400
In-Reply-To: <471C3E0B.2070602@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Date: Mon, 22 Oct 2007 14:07:07 +0800

> When kernel receives a package with a wrong destination ipv4 address, it can't increase "InAddrErrors" number correctly.
> InAddrErrors is located in /proc/net/snmp.
> 
> This is a patch for fixing this problem.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

This patch looks fine, but I really don't handle 2.4.x
kernel patches for networking as 2.6.x takes enough of
my time and effort.
