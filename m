From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8519] New: NAT prerouting over tun interface
 broken
Date: Tue, 22 May 2007 00:28:07 +0200
Message-ID: <46521CF7.3070601@trash.net>
References: <200705212005.l4LK5aJk029945@fire-2.osdl.org> <20070521131343.cbf3bcaa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: elendil@planet.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65424 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759213AbXEUW2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 18:28:14 -0400
In-Reply-To: <20070521131343.cbf3bcaa.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Mon, 21 May 2007 13:05:36 -0700
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>>Problem Description:
>>I have the hercules s/390 emulator running on an EM64T host, both running 
>>Debian unstable. I use a tun interface, a second IP address on eth0 and 
>>iptables/nat so the emulator has it's own address on my local network.
>>
>>With 2.6.21.1 on the host, networking between the emulator and the host system 
>>is fine (I can ssh from the host into the emulator without problems), but 
>>communication from the emulator with other boxes is broken. Other boxes also 
>>don't see the emulator if I ping its external address.
>>
>>If I ping another box on my LAN from the emulator while running wireshark on 
>>the host, I can see that:
>>- the echo request gets sent OK
>>- the other box replies OK
>>- the host receives the echo reply
>>- but the tun interface never gets it.
>>
>>If I boot the host with 2.6.20 everything works fine again.


Please post the output of lsmod and cat /proc/net/ip_conntrack after
sending a ping.

