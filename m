From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH net-next v2] net: ipv6: Fix UDP early demux lookup with
 udp_l3mdev_accept=0
Date: Mon, 17 Apr 2017 23:51:11 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15B8090F@cnshjmbx02>
References: <1492471495-13073-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <edumazet@google.com>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        "dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "rshearma@brocade.com" <rshearma@brocade.com>,
        "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:50756 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756830AbdDQXvV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 19:51:21 -0400
In-Reply-To: <1492471495-13073-1-git-send-email-subashab@codeaurora.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Subash Abhinov Kasiviswanathan
> Sent: Tuesday, April 18, 2017 7:25 AM
> To: dsa@cumulusnetworks.com; davem@davemloft.net;
> netdev@vger.kernel.org; rshearma@brocade.com; eric.dumazet@gmail.com
> Cc: Subash Abhinov Kasiviswanathan; Eric Dumazet
> Subject: [PATCH net-next v2] net: ipv6: Fix UDP early demux lookup with
> udp_l3mdev_accept=0
> 
> -	return sk;
> +	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
> +		if (INET6_MATCH(sk, net, rmt_addr, loc_addr, ports, dif))
> +			return sk;
> +		break;
I think break here should remove ?
> +	}
> +	return NULL;
>  }
> --
> 1.9.1
