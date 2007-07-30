From: Patrick McHardy <kaber@trash.net>
Subject: Re: source interface ping bug ?
Date: Mon, 30 Jul 2007 18:19:42 +0200
Message-ID: <46AE0F9E.5030003@trash.net>
References: <d39c36500707270130j3eac7f44qb3a4c87496a1296b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nano bug <linnewbye@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40640 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S939733AbXG3QUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 12:20:05 -0400
In-Reply-To: <d39c36500707270130j3eac7f44qb3a4c87496a1296b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nano bug wrote:
> [...]
> using source interface :
> 
> root@darkstar:~/iputils# ./ping -I eth2 87.248.113.14
> PING 87.248.113.14 (87.248.113.14) from 86.106.19.75 eth2: 56(84) bytes of data.
>>From 86.106.19.75 icmp_seq=1 Destination Host Unreachable

> root@darkstar:~# tcpdump -i eth2 -vvv -n host 87.248.113.14 and host
> 86.106.19.75
> tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size 96 bytes
> 01:19:24.292911 arp who-has 87.248.113.14 tell 86.106.19.75


Are you using (or running) NAT locally? What do your routing tables look
like?
