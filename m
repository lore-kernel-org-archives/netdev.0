From: David Miller <davem@davemloft.net>
Subject: Re: [Resent] [PATCH 1/2] udp: Fix the SNMP counter of
 UDP_MIB_INDATAGRAMS
Date: Mon, 03 Nov 2008 00:08:10 -0800 (PST)
Message-ID: <20081103.000810.145688028.davem@davemloft.net>
References: <490E5DB5.4020407@cn.fujitsu.com>
	<20081102.234625.135160979.davem@davemloft.net>
	<alpine.LRH.2.00.0811030959340.19760@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53022
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754598AbYKCIIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 03:08:35 -0500
In-Reply-To: <alpine.LRH.2.00.0811030959340.19760@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Savola <pekkas@netcore.fi>
Date: Mon, 3 Nov 2008 10:01:42 +0200 (EET)

> On Sun, 2 Nov 2008, David Miller wrote:
> > From: Wei Yongjun <yjwei@cn.fujitsu.com>
> > Date: Mon, 03 Nov 2008 10:11:01 +0800
> >
> >> @@ -158,6 +159,8 @@ try_again:
> >>  	else if (copied < ulen)
> >>  		msg->msg_flags |= MSG_TRUNC;
> >>  +	is_udp4 = (skb->protocol == htons(ETH_P_IP));
> >> +
> 
> Does this work with non-ethernet link-layers ?

Regardless of link layer, the skb gets marked with
the ethernet protocol codes.
