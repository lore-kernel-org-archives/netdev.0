From: David Miller <davem@davemloft.net>
Subject: Re: net/mlx4_en: Pad ethernet packets smaller than 17 bytes
Date: Thu, 27 Feb 2014 15:36:01 -0500 (EST)
Message-ID: <20140227.153601.1100017228027738567.davem@davemloft.net>
References: <20140227140203.GA13112@mtl-eit-vdi-22.mtl.labs.mlnx>
	<1393512255.26794.20.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140227154635.GA24226@mtl-eit-vdi-22.mtl.labs.mlnx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, eugenia@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbaB0UgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 15:36:04 -0500
In-Reply-To: <20140227154635.GA24226@mtl-eit-vdi-22.mtl.labs.mlnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 27 Feb 2014 17:46:37 +0200

> On 27/02/14 06:44 -0800, Eric Dumazet wrote:
>> On Thu, 2014-02-27 at 16:02 +0200, Amir Vadai wrote:
>> >  
>> > Yes, skb will not be classified as inline-able if nr_frags != 1.
>> > See is_inline()
> 
> Maybe I wasn't accurate enough. inline-able skb must have:
> 1. skb->len < inline_thold 
> 2. nr_frags <= 1
> 
> Default value for inline_thold is 104 and it is a module parameter
> that can be changed.

BTW, the canonical way to deal with minimum length requirements is to
use skb_padto().
