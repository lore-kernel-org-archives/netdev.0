From: David Miller <davem@davemloft.net>
Subject: Re: possible kernel oops from user MSS
Date: Wed, 10 Nov 2010 21:33:13 -0800 (PST)
Message-ID: <20101110.213313.71108940.davem@davemloft.net>
References: <AANLkTimMDMb74-3E9vhFxZ5Dgeuk3HMzPZVjwCj+yFEJ@mail.gmail.com>
	<20101110.124119.102563803.davem@davemloft.net>
	<4CDB7BD5.6030204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: schen@mvista.com, netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40023
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751177Ab0KKFct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 00:32:49 -0500
In-Reply-To: <4CDB7BD5.6030204@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Thu, 11 Nov 2010 13:15:01 +0800

> In tcp_connect_init(), if tcp_header_len includes TCPOLEN_TSTAMP_ALIGNED(12 bytes)
> and TCPOLEN_MD5SIG_ALIGNED(20 bytes).

If you knew this, why didn't you mention it in your initial report? :-/

I'll make the minimum 64 or something like that.
