From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Mon, 23 Jul 2012 23:59:31 -0700 (PDT)
Message-ID: <20120723.235931.725099984853258732.davem@davemloft.net>
References: <A4FD513AF09D40849B8A75C371F1D431@realtek.com.tw>
	<20120720210107.GA28118@electric-eye.fr.zoreil.com>
	<CEE7FFC13FF3495C9771B87B8F199BA7@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53282 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185Ab2GXG7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 02:59:32 -0400
In-Reply-To: <CEE7FFC13FF3495C9771B87B8F199BA7@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: hayeswang <hayeswang@realtek.com>
Date: Tue, 24 Jul 2012 14:34:04 +0800

>   Francois Romieu [mailto:romieu@fr.zoreil.com] 
>> Sent: Saturday, July 21, 2012 5:01 AM
>> To: Hayeswang
>> Cc: 'David Miller'; eric.dumazet@gmail.com; netdev@vger.kernel.org
>> Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
>> 
> [...]
>> 
>> Btw, would there be any point in setting the TcpHeaderOffset field for
>> the post-8168c chipsets ?
> 
> It is used to tell the haredware where the TCP header starts from. I think it is
> reserved for ipv6.

I still have not seen a good explanation why the chip modifies fields
in the packet, such as the length, when we ask it only to compute the
checksum?
