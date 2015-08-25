From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Tue, 25 Aug 2015 16:03:02 -0700 (PDT)
Message-ID: <20150825.160302.947112090610933000.davem@davemloft.net>
References: <20150825.141540.472110106537790402.davem@davemloft.net>
	<20150825225406.GA24297@electric-eye.fr.zoreil.com>
	<20150825.155921.399025256241133988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinschen@redhat.com, netdev@vger.kernel.org, hayeswang@realtek.com,
	ivecera@redhat.com, nic_swsd@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756114AbbHYXDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:03:04 -0400
In-Reply-To: <20150825.155921.399025256241133988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 25 Aug 2015 15:59:21 -0700 (PDT)

> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Wed, 26 Aug 2015 00:54:06 +0200
> 
>>> Bringing the interface is brought down/up should not reset the
>>> counters.
>> 
>> Afaiks rtl8169_tc_offsets.inited in rtl8169_init_counter_offsets
>> takes care of it: it's set during the first open() after probe().
> 
> Ok, then it's fine.

And as such I've applied this patch, thanks.
