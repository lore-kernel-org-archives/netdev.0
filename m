From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [PATCH net] qlge: remove NETIF_F_TSO6 flag
Date: Fri, 11 Jan 2013 21:48:52 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E03F661@avmb2.qlogic.org>
References: <1357894374-10767-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ron Mercer <ron.mercer@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.13] ([216.32.180.13]:43546 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754594Ab3AKVvL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 16:51:11 -0500
In-Reply-To: <1357894374-10767-1-git-send-email-amwang@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>From: Cong Wang [mailto:amwang@redhat.com] 
>Sent: Friday, January 11, 2013 12:53 AM
>To: netdev
>Cc: Jitendra Kalsaria; Ron Mercer; Dept-Eng Linux Driver; David Miller; Cong Wang
>Subject: [PATCH net] qlge: remove NETIF_F_TSO6 flag
>
>It is werid that qlge driver supports NETIF_F_TSO6 but
>not NETIF_F_IPV6_CSUM. This also causes some kernel warning [1]
>when VLAN device setups on a qlge interface.
>
>I think the qlge hardware doesn't support NETIF_F_IPV6_CSUM,
>so we have to just remove the NETIF_F_TSO6 flag.
>
>After this patch, the TCP/IPv6 traffic becomes normal again,
>no kernel warnings any more.
>
>NOTE: I only tested it on 2.6.32 kernel, even if the upstream
>kernel could fix this automatically (it is hard to track NETIF*
>flags), removing it is also safe.
>
>1. https://bugzilla.redhat.com/show_bug.cgi?id=891839
>
>Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>Cc: Ron Mercer <ron.mercer@qlogic.com>
>Cc: linux-driver@qlogic.com
>Cc: David S. Miller <davem@davemloft.net>
>Signed-off-by: Cong Wang <amwang@redhat.com>

Thanks!
Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
