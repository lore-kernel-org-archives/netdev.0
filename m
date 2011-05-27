From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Bugme-new] [Bug 35862] New: arp requests from wrong src IP
Date: Fri, 27 May 2011 08:27:23 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1105270814360.1520@ja.ssi.bg>
References: <bug-35862-10286@https.bugzilla.kernel.org/> <20110525163137.6f04f26e.akpm@linux-foundation.org> <20110525.215222.22117057747103565.davem@davemloft.net> <201105260400.22814.matare@lih.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-734294189-1306474044=:1520"
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: =?UTF-8?Q?Victor_Matar=C3=A9?= <matare@lih.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56872 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751306Ab1E0F0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 01:26:10 -0400
In-Reply-To: <201105260400.22814.matare@lih.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-734294189-1306474044=:1520
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Thu, 26 May 2011, Victor Mataré wrote:

> Examining the host which now has 137.226.164.2 (used to have 137.226.164.13):
> 
> # ip addr show dev eth0
> 4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
>      link/ether 00:e0:81:41:1f:e4 brd ff:ff:ff:ff:ff:ff
>      inet 137.226.164.2/24 brd 137.226.164.255 scope global eth0
>      inet 192.168.23.2/24 brd 137.226.164.255 scope global eth0:0
> [...]
> 
> Sorry, got confused with all the swapping. I'm *not* keeping the old address around, it's completely *gone*, from both ifconfig and ip. But still it's being used as arp src address. That's what this bug is about. Sorry for the confusion.

	It looks strange. Can you confirm the following things:

- the kernel version

- the order of 'ip' command used to add and change IPs on this box

- output of 'ip route list table local' after IPs are changed and
before starting arping

- output of 'strace arping', I assume it is using getsockname
after UDP connect

- any reason to use broadcast 137.226.164.255 for all addresses?

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-734294189-1306474044=:1520--
