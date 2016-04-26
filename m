From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: fix failure during registration v3
Date: Tue, 26 Apr 2016 15:19:05 -0400 (EDT)
Message-ID: <20160426.151905.237092605462953849.davem@davemloft.net>
References: <1461449012-7401-1-git-send-email-fruggeri@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, maheshb@google.com
To: fruggeri@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827AbcDZTTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 15:19:11 -0400
In-Reply-To: <1461449012-7401-1-git-send-email-fruggeri@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Ruggeri <fruggeri@arista.com>
Date: Sat, 23 Apr 2016 15:03:32 -0700

> If macvlan_common_newlink fails in register_netdevice after macvlan_init
> then it decrements port->count twice, first in macvlan_uninit (from
> register_netdevice or rollback_registered) and then again in
> macvlan_common_newlink.
> A similar problem may exist in the ipvlan driver.
> This patch consolidates modifications to port->count into macvlan_init
> and macvlan_uninit (thanks to Eric Biederman for suggesting this approach).
> 
> v3: remove macvtap specific bits.
> 
> Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>

Applied.
