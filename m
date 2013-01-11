From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qlge: remove NETIF_F_TSO6 flag
Date: Fri, 11 Jan 2013 15:59:19 -0800 (PST)
Message-ID: <20130111.155919.809159136231664892.davem@davemloft.net>
References: <1357894374-10767-1-git-send-email-amwang@redhat.com>
	<BECD8E8A1B550B48A1BF97C13991F60E03F661@avmb2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Linux-Driver@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755380Ab3AKX7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 18:59:20 -0500
In-Reply-To: <BECD8E8A1B550B48A1BF97C13991F60E03F661@avmb2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Fri, 11 Jan 2013 21:48:52 +0000

> 
>>From: Cong Wang [mailto:amwang@redhat.com] 
>>Sent: Friday, January 11, 2013 12:53 AM
>>To: netdev
>>Cc: Jitendra Kalsaria; Ron Mercer; Dept-Eng Linux Driver; David Miller; Cong Wang
>>Subject: [PATCH net] qlge: remove NETIF_F_TSO6 flag
>>
>>It is werid that qlge driver supports NETIF_F_TSO6 but
>>not NETIF_F_IPV6_CSUM. This also causes some kernel warning [1]
>>when VLAN device setups on a qlge interface.
>>
>>I think the qlge hardware doesn't support NETIF_F_IPV6_CSUM,
>>so we have to just remove the NETIF_F_TSO6 flag.
>>
>>After this patch, the TCP/IPv6 traffic becomes normal again,
>>no kernel warnings any more.
>>
>>NOTE: I only tested it on 2.6.32 kernel, even if the upstream
>>kernel could fix this automatically (it is hard to track NETIF*
>>flags), removing it is also safe.
>>
>>1. https://bugzilla.redhat.com/show_bug.cgi?id=891839
>>
>>Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>>Cc: Ron Mercer <ron.mercer@qlogic.com>
>>Cc: linux-driver@qlogic.com
>>Cc: David S. Miller <davem@davemloft.net>
>>Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> Thanks!
> Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Applied.
