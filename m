From: David Miller <davem@davemloft.net>
Subject: Re: [TCP] IPV6 : Change a divide into a right shift in
 tcp_v6_send_ack()
Date: Fri, 21 Dec 2007 03:57:17 -0800 (PST)
Message-ID: <20071221.035717.243469952.davem@davemloft.net>
References: <476B574E.80601@cosmosbay.com>
	<20071221.155030.131184865.yoshfuji@linux-ipv6.org>
	<476BA2F8.1090102@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, dada1@cosmosbay.com,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41596
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750920AbXLUL5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 06:57:18 -0500
In-Reply-To: <476BA2F8.1090102@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 21 Dec 2007 06:26:48 -0500

> YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > In article <476B574E.80601@cosmosbay.com> (at Fri, 21 Dec 2007 07:03:58 +0100), Eric Dumazet <dada1@cosmosbay.com> says:
> > 
> >> Because tot_len is signed in tcp_v6_send_ack(), tot_len/4 forces compiler
> >> to emit an integer divide, while we can help it to use a right shift,
> >> less expensive.
> > 
> > Are you really sure?
> > At least, gcc-4.1.2-20061115 (debian) does not make any difference.
> 
> Quite true -- thus it is a matter of taste to the programmer.

Not true, the code output does change, check your optimize-for-size
kernel config setting.

This was discussed and explained later in this thread, and I also
explained it to you on IRC Jeff ;-)
