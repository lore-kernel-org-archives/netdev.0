From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [net-next (TAKE 2) 0/4] IPv6 over Firewire
Date: Sun, 10 Feb 2013 19:48:53 +0900
Message-ID: <51177B15.3030405@linux-ipv6.org>
References: <5117620A.4050005@linux-ipv6.org> <51177689.4070904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	davem@davemloft.net, stefanr@s5r6.in-berlin.de,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:57015 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753737Ab3BJKsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 05:48:55 -0500
In-Reply-To: <51177689.4070904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:

> Were you able to test your changes against different IP over firewire
> implementations? If not, I will test against the existing Linux
> implementation, MacOSX and Windows.

I have tested against MacOS X 10.5.8.

ARP and ping works but unfortunately NDP does not seem to work.

If I assign static NDP entry on Linux, ping6 ff02::1%fw0 from MacOS works
well.

I checked tcpdump on both side, and I guess this is because MacOS is broken;
- tcpdump on Linux side complains that ICMP checksum is incorrect.
- tcpdump on MacOS side says that length of Link-layer address option is 2 (16)
  instead of 3 (24).

I think we should check others like FreeBSD as well.

Thanks.

--yoshfuji
