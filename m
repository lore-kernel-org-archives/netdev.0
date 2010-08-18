From: Dmitry Kozlov <xeb@mail.ru>
Subject: =?koi8-r?Q?Re=3A_[PATCH_v2_1/3]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Wed, 18 Aug 2010 09:56:54 +0400
Message-ID: <E1Olbdu-0000eJ-00.xeb-mail-ru@f251.mail.ru>
References: <20100816.205316.226783098.davem@davemloft.net>
Reply-To: Dmitry Kozlov <xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from f251.mail.ru ([217.69.128.176]:47055 "EHLO f251.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449Ab0HRF46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 01:56:58 -0400
In-Reply-To: <20100816.205316.226783098.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Please make the following changes:
> 
> 1) Remove all of the "DEBUG" stuff.  First of all, you should never
>    TAB indent "#ifdef DEBUG" CPP checks like that, it's awfully
>    ugly and makes the code hard to read.  Next you can use
>    pr_debug() or similar for things like this.
> 
> 2) Combine all three patches into one single patch including everything.
>    There is no need to split things up like this.
> 
> Thank you.

done
