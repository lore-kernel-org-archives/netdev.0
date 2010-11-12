From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix checksum broken
Date: Fri, 12 Nov 2010 23:47:46 +0100
Message-ID: <20101112224746.GA6676@electric-eye.fr.zoreil.com>
References: <4CDD13BD.7060109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 254.185.140-88.rev.gaoland.net ([88.140.185.254]:47066 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757572Ab0KLWs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 17:48:28 -0500
Content-Disposition: inline
In-Reply-To: <4CDD13BD.7060109@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shan Wei <shanwei@cn.fujitsu.com> :
> If r8196 received packets with invalid sctp/igmp(not tcp, udp) checksum, r8196 set skb->ip_summed
> wit CHECKSUM_UNNECESSARY. This cause that upper protocol don't check checksum field.

...

Which kind of device do you use : PCI-E 8168 / 810x or PCI 8169 ?

Have a nice night.

-- 
Ueimor
