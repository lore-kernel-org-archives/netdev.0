From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: Re: [PATCH 9/9 V2] mlx4_en: Multiqueue support
Date: Tue, 30 Dec 2008 18:54:58 +0200
Message-ID: <495A5262.50100@mellanox.co.il>
References: <49589EF5.8070800@mellanox.co.il> <20081229.184109.77843771.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:44784 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750887AbYL3Q4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2008 11:56:11 -0500
In-Reply-To: <20081229.184109.77843771.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> You are not supposed to provide a driver private function
> to hash the traffic.
> 
> The generic code already hashes traffic for you, and whatever
> it doesn't handle currently will be handled in the future.
> The generic code is where gaps should be filled in.
> 
> The override function pointer is only for wireless which has
> special needs in queue selection that have nothing to do with
> flow seperation.
> 

The generic hash function (simple_tx_hash) doesn't consider Vlan priority when making the hash.
When working in Per Priority Pause mode, packets with different Vlan priority should be sent from
a different transmit queue. How can we ensure this without using private hashing function?

Thank you,
Yevgeny.
