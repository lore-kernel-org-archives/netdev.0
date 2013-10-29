From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: pass correct vlan id to multicast code
Date: Tue, 29 Oct 2013 17:40:25 -0400 (EDT)
Message-ID: <20131029.174025.628235138059662194.davem@davemloft.net>
References: <1382989507-23061-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	makita.toshiaki@lab.ntt.co.jp
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab3J2Vk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 17:40:26 -0400
In-Reply-To: <1382989507-23061-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Mon, 28 Oct 2013 15:45:07 -0400

> Currently multicast code attempts to extrace the vlan id from
> the skb even when vlan filtering is disabled.  This can lead
> to mdb entries being created with the wrong vlan id.
> Pass the already extracted vlan id to the multicast
> filtering code to make the correct id is used in
> creation as well as lookup.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied, thanks Vlad and others.
