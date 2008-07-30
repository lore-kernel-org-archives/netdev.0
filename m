From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: datagram_send_ctl() should exit immediately when
 an error occured
Date: Tue, 29 Jul 2008 23:58:06 -0700 (PDT)
Message-ID: <20080729.235806.263807229.davem@davemloft.net>
References: <488FC443.1080905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: miaox@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55823
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751397AbYG3G6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 02:58:10 -0400
In-Reply-To: <488FC443.1080905@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Miao Xie <miaox@cn.fujitsu.com>
Date: Wed, 30 Jul 2008 09:30:43 +0800

> When an error occured, datagram_send_ctl() should exit immediately rather than
> continue to run the for loop. Otherwise, the variable err might be changed and
> the error might be hidden.
> 
> Fix this bug by using "goto" instead of "break".
> 
> Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>

Applied, thanks.
