From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH bug-fix v2] net: vlan: enable soft features regardless
 of underlying device
Date: Tue, 05 Jul 2011 20:43:36 -0700 (PDT)
Message-ID: <20110705.204336.1114459637899394110.davem@davemloft.net>
References: <4E13C3AC.3050407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755987Ab1GFDnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 23:43:42 -0400
In-Reply-To: <4E13C3AC.3050407@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Wed, 06 Jul 2011 10:08:44 +0800

> If gso/gro feature of underlying device is turned off，
> then new created vlan device never can turn gso/gro on. 
> 
> Although underlying device don't support TSO, we still
> should use software segments for vlan device.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied to net-2.6, thanks.
