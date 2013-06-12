From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] veth: remove redundant call of dev_alloc_name
Date: Wed, 12 Jun 2013 01:21:37 -0700 (PDT)
Message-ID: <20130612.012137.2298885668067547485.davem@davemloft.net>
References: <1370780120-8495-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	xemul@openvz.org, ebiederm@xmission.com
To: honkiko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755423Ab3FLIVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 04:21:39 -0400
In-Reply-To: <1370780120-8495-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <honkiko@gmail.com>
Date: Sun,  9 Jun 2013 20:15:20 +0800

> it's called in the following register_netdevice. No need to call it
> here.
> Tested with "ip link add type veth" and "ip link add xxx%d type veth".
> 
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

Applied, thank you.
