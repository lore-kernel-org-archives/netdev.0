From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Wed, 18 Jul 2012 23:44:22 +0200
Message-ID: <20120718214422.GA18207@electric-eye.fr.zoreil.com>
References: <AC35CD5731C3479B9BF5E53BF541A81F@realtek.com.tw> <20120718.092346.1263036873056516097.davem@davemloft.net> <20120718201201.GC14149@electric-eye.fr.zoreil.com> <20120718.132840.1571938255177607234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52897 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270Ab2GRV5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:57:09 -0400
Content-Disposition: inline
In-Reply-To: <20120718.132840.1571938255177607234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> A NETDEV_TX_OK return means we accepted the SKB, it doesn't look like
> that's what you are doing in the skb_padto() failure path.

?

- skb_padto fails
  (original skb is implicitely freed)
- skb_padto returns error status (!= 0)
- rtl8169_tso_csum returns false
- start_xmit returns NETDEV_TX_OK. 

I'll search the missing "!" after some sleep if that's what you are talking
about. Otherwise than that, I don't get it.

-- 
Ueimor
