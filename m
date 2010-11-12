From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: fix checksum broken
Date: Fri, 12 Nov 2010 12:44:01 -0800 (PST)
Message-ID: <20101112.124401.35026128.davem@davemloft.net>
References: <4CDD13BD.7060109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50874
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932417Ab0KLUng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:43:36 -0500
In-Reply-To: <4CDD13BD.7060109@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 12 Nov 2010 18:15:25 +0800

> If r8196 received packets with invalid sctp/igmp(not tcp, udp) checksum, r8196 set skb->ip_summed
> wit CHECKSUM_UNNECESSARY. This cause that upper protocol don't check checksum field.
> 
> I am not family with r8196 driver. I try to guess the meaning of RxProtoIP and IPFail.
> RxProtoIP stands for received IPv4 packet that upper protocol is not tcp and udp. 
> !(opts1 & IPFail) is true means that driver correctly to check checksum in IPv4 header.
> 
> If it's right, I think we should not set ip_summed wit CHECKSUM_UNNECESSARY for my sctp packets
> with invalid checksum. 
> 
> If it's not right, please tell me. 
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Francois, please review, it looks correct to my eyes.
