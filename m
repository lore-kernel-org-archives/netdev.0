From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] r8152: reduce the number of Tx
Date: Sun, 31 Aug 2014 21:38:23 -0700 (PDT)
Message-ID: <20140831.213823.1615189696117720659.davem@davemloft.net>
References: <1394712342-15778-24-Taiwan-albertk@realtek.com>
	<20140829.202504.655684636693672249.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2516A75@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbaIAEi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 00:38:27 -0400
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2516A75@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 1 Sep 2014 02:46:38 +0000

>  From: David Miller [mailto:davem@davemloft.net] 
> [...]
>> This driver has a loop that iterates MAX_TX times to initialize both
>> the RX and TX buffers.
>> 
>> So if they are not equal, it can't possibly work.
> 
> Excuse me. I don't find that the "RTL8152_MAX_TX" is used by
> rx buffer. The rx buffer only use "RTL8152_MAX_RX". Although 
> the tx buffer size is determined by "rx_buf_sz", the tx buffers
> are independent of rx buffers.

Ok, but that is really confusing code.
