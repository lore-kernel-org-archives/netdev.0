From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: jme: UDP checksum error, and lots of them
Date: Sat, 4 Dec 2010 00:02:50 +0100
Message-ID: <20101203230250.GA3612@electric-eye.fr.zoreil.com>
References: <alpine.LNX.2.01.1012020430190.4157@obet.zrqbmnf.qr> <20101201.200935.71110482.davem@davemloft.net> <20101202042820.M98672@cooldavid.org> <20101201.215916.104055114.davem@davemloft.net> <20101202231546.GA3507@electric-eye.fr.zoreil.com> <alpine.LNX.2.01.1012030044440.22334@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cooldavid@cooldavid.org,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39873 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483Ab0LCXDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 18:03:02 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1012030044440.22334@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt <jengelh@medozas.de> :
> On Friday 2010-12-03 00:15, Francois Romieu wrote:
> >David Miller <davem@davemloft.net> :
> >[...]
> >> Something isn't right here.  The only thing that makes sense is if
> >> the tcpdump checksum validation is wrong for some reason.  Because
> >> only then could we give a reason for the UDP frames to not be
> >> dropped before vpnc can see them.
> >
> >Wild guess : 192.168... is the local address and tcpdump chokes on
> >an outgoing, yet-not-checksummed packet.
> 
> Then the checksums of all other packets I am emitting would also be 0000 
> or wrong, which isn't the case.

No. :o)

net/ipv4/udp.c::udp4_hwcsum_outgoing provides a packet data length
dependent partial checksum and it checksums fragments.

-- 
Ueimor
