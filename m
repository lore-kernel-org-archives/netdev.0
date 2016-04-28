From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v2] ipvlan: Fix failure path in dev registration
 during link creation
Date: Thu, 28 Apr 2016 17:23:24 -0400 (EDT)
Message-ID: <20160428.172324.972705903601258798.davem@davemloft.net>
References: <1461794367-39825-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbcD1VXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 17:23:32 -0400
In-Reply-To: <1461794367-39825-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed, 27 Apr 2016 14:59:27 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> When newlink creation fails at device-registration, the port->count
> is decremented twice. Francesco Ruggeri (fruggeri@arista.com) found
> this issue in Macvlan and the same exists in IPvlan driver too.
> 
> While fixing this issue I noticed another issue of missing unregister
> in case of failure, so adding it to the fix which is similar to the
> macvlan fix by Francesco in commit 308379607548 ("macvlan: fix failure
> during registration v3")
> 
> Reported-by: Francesco Ruggeri <fruggeri@arista.com>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.
