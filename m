From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: next-20090318: sunhme does not transmit packets
Date: Wed, 18 Mar 2009 19:58:40 +0300
Message-ID: <a4423d670903180958j4847717eh99a41534633dd314@mail.gmail.com>
References: <a4423d670903180734w7270a4f3qa2af3981b969436c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:36447 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755683AbZCRQ6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 12:58:43 -0400
In-Reply-To: <a4423d670903180734w7270a4f3qa2af3981b969436c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/3/18 Alexander Beregalov <a.beregalov@gmail.com>:
> Hi
>
> Ultra 10 can boot, it receives DHCP answer, ssh works, but few minutes
> after machine becomes unresponsible by net at all.
> It does not respond even on ARP requests.
>
> On Sparc host I see that `TX packets` does not grow, but RX grows.
> The state of the interface is
> UP BROADCAST RUNNING MULTICAST
>
> There is no relevant kernel messages in dmesg.
>
> next-20090317 worked fine.
>
>
> Let me know if I can help.
>

I have reproduced it on next-20090318 for the second time, but still
do not know how.
next-20090317 might be affected.

Now both packet counters grow, but tcpdump cannot capture any packet.
