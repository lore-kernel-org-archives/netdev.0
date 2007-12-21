From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [TCP] IPV6 : Change a divide into a right shift in
 tcp_v6_send_ack()
Date: Fri, 21 Dec 2007 15:50:30 +0900 (JST)
Message-ID: <20071221.155030.131184865.yoshfuji@linux-ipv6.org>
References: <476B574E.80601@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44207 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbXLUGtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 01:49:55 -0500
In-Reply-To: <476B574E.80601@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <476B574E.80601@cosmosbay.com> (at Fri, 21 Dec 2007 07:03:58 +0100), Eric Dumazet <dada1@cosmosbay.com> says:

> Because tot_len is signed in tcp_v6_send_ack(), tot_len/4 forces compiler
> to emit an integer divide, while we can help it to use a right shift,
> less expensive.

Are you really sure?
At least, gcc-4.1.2-20061115 (debian) does not make any difference.

And, IMHO, because shift for signed variable is fragile, so we should
avoid using it.

--yoshfuji
