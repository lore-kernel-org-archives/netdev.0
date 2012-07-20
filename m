From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Fri, 20 Jul 2012 09:17:36 -0700 (PDT)
Message-ID: <20120720.091736.2184590636579395133.davem@davemloft.net>
References: <1342649136.2626.3757.camel@edumazet-glaptop>
	<20120718.152405.1083396282134539674.davem@davemloft.net>
	<EF06A7B3C1E6432BB660CDEF8E1D2A1B@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab2GTQRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 12:17:40 -0400
In-Reply-To: <EF06A7B3C1E6432BB660CDEF8E1D2A1B@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: hayeswang <hayeswang@realtek.com>
Date: Fri, 20 Jul 2012 15:14:26 +0800

> I find that the total length field of IP header would be modified if the hw
> checksum is enabled. Therefore, skb_padto + hw checksum wouldn't work. The
> software checksum is necessary.

It's really strange that the hardware has any reason to update the IP
header length field when it is asked to compute the checksum.
