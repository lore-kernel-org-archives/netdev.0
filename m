From: David Miller <davem@davemloft.net>
Subject: Re: possible kernel oops from user MSS
Date: Fri, 12 Nov 2010 15:26:07 -0800 (PST)
Message-ID: <20101112.152607.193708973.davem@davemloft.net>
References: <20101110.124119.102563803.davem@davemloft.net>
	<AANLkTin-gXceUQxKvQeP8Nc8oXZDJnyjoFUjYD5x_g_y@mail.gmail.com>
	<4CDDC6EE.2010005@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mzhang@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39750
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932073Ab0KLXZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 18:25:42 -0500
In-Reply-To: <4CDDC6EE.2010005@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Min Zhang <mzhang@mvista.com>
Date: Fri, 12 Nov 2010 14:59:58 -0800

> Regarding commit 7a1abd08d52fdeddb3e9a5a33f2f15cc6a5674d2 ("tcp:
> Increase TCP_MAXSEG socket option minimum"). What is the reason
> TCP_MAXSEG minimum be 64? Isn't the exact be 40 which is
> TCPOLEN_MD5SIG_ALIGNED(20) + TCPOLEN_TSTAMP_ALIGNED(12) + 8?
> 
> Or is it better to use TCP_MIN_MSS from tcp.h:
> 
> /* Minimal accepted MSS. It is (60+60+8) - (20+20). */
> #define TCP_MIN_MSS        88U

I suppose TCP_MIN_MSS would be better to use, I'll make that
change, thanks.
