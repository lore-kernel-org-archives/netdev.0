From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 over Firewire
Date: Sun, 23 Dec 2012 21:09:44 +0900
Message-ID: <50D6F488.7060308@linux-ipv6.org>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org> <50D4ACFA.6040901@gmail.com> <50D4BD2F.7060006@linux-ipv6.org> <50D54ED9.6090908@gmail.com> <50D6BF6F.2030207@linux-ipv6.org> <50D6E73F.70301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:35773 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751860Ab2LWMJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 07:09:46 -0500
In-Reply-To: <50D6E73F.70301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:
>> net/ipv6/ndisc.c SHOULD build full NDP messages for IPv6
>> over IEEE1394 as we do it for Infiniband.
>>
>> Please, please do not try to mangle them in the driver.
>>
> As far as I understand the code for Infiniband (and the corresponding RFC4391) I just see the introduction of two pad bytes. Moreover, I see that ndisc_build_skb calls ndisc_fill_addr_option which copies dev->dev_addr. Maybe the so called Queue Pair Number (QPN) is already included in dev->dev_addr. If not, I guess the Infiniband driver will also mangle the QPN into the link layer option. If not, this seems only possible because the format for IPv6 link layer option (IB) and IPv4/ARP (IB) has the same format.

Please, please try best not to mangle packets
and keep/make IPsec, SEND right.

Well, Infiniband's hardware length (INFINIBAND_ALEN) is 20,
which means that it includes reserved and QPN field.
Moreover Infiniband driver uses neighbor notification
mechanism.

I think Firewire can use that as well.
What do you think?

--yoshfuji
