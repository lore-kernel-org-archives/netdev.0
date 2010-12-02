From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: jme: UDP checksum error, and lots of them
Date: Fri, 3 Dec 2010 00:15:46 +0100
Message-ID: <20101202231546.GA3507@electric-eye.fr.zoreil.com>
References: <alpine.LNX.2.01.1012020430190.4157@obet.zrqbmnf.qr> <20101201.200935.71110482.davem@davemloft.net> <20101202042820.M98672@cooldavid.org> <20101201.215916.104055114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cooldavid@cooldavid.org, jengelh@medozas.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48096 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757180Ab0LBXP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:15:58 -0500
Content-Disposition: inline
In-Reply-To: <20101201.215916.104055114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Something isn't right here.  The only thing that makes sense is if
> the tcpdump checksum validation is wrong for some reason.  Because
> only then could we give a reason for the UDP frames to not be
> dropped before vpnc can see them.

Wild guess : 192.168... is the local address and tcpdump chokes on
an outgoing, yet-not-checksummed packet.

-- 
Ueimor
