From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]: Can not set the IPV6_PKTINFO option
Date: Mon, 16 Jul 2007 22:07:30 +0900 (JST)
Message-ID: <20070716.220730.18710682.yoshfuji@linux-ipv6.org>
References: <200707161341.23419@strip-the-willow>
	<20070716.215605.106156812.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48072 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758011AbXGPNGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 09:06:48 -0400
In-Reply-To: <20070716.215605.106156812.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070716.215605.106156812.yoshfuji@linux-ipv6.org> (at Mon, 16 Jul 2007 21:56:05 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <200707161341.23419@strip-the-willow> (at Mon, 16 Jul 2007 13:41:23 +0100), Gerrit Renker <gerrit@erg.abdn.ac.uk> says:
> 
> > [IPv6]: Can not set the IPV6_PKTINFO option
> > 
> > The Linux manpage of ipv6(7) mentions the IPV6_PKTINFO option (and it is defined in header
> > files), but there is no setsockopt support for it. Aliasing to IPV6_RECVPKTINFO fixes this,
> > and checking datagram_recv_ctl() in net/ipv6/datagram.c confirms that this works as 
> > expected from the API.
> > 
> > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> 
> NAK.  It is obsolete.

I meant, the manpage is outdated.

Current IPV6_PKTINFO is not equal to IPV6_RECVPKTINFO
but a sticky option to set source address / interface
for outgoing packet.

--yoshfuji
