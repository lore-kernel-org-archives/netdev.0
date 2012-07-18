From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Thu, 19 Jul 2012 00:05:36 +0200
Message-ID: <1342649136.2626.3757.camel@edumazet-glaptop>
References: <AC35CD5731C3479B9BF5E53BF541A81F@realtek.com.tw>
	 <20120718.092346.1263036873056516097.davem@davemloft.net>
	 <20120718201201.GC14149@electric-eye.fr.zoreil.com>
	 <20120718.132840.1571938255177607234.davem@davemloft.net>
	 <20120718214422.GA18207@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hayeswang@realtek.com,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:50330 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898Ab2GRWFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 18:05:40 -0400
Received: by qcro28 with SMTP id o28so1299987qcr.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 15:05:40 -0700 (PDT)
In-Reply-To: <20120718214422.GA18207@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 23:44 +0200, Francois Romieu wrote:
> David Miller <davem@davemloft.net> :
> [...]
> > A NETDEV_TX_OK return means we accepted the SKB, it doesn't look like
> > that's what you are doing in the skb_padto() failure path.
> 
> ?
> 
> - skb_padto fails
>   (original skb is implicitely freed)
> - skb_padto returns error status (!= 0)
> - rtl8169_tso_csum returns false
> - start_xmit returns NETDEV_TX_OK. 
> 
> I'll search the missing "!" after some sleep if that's what you are talking
> about. Otherwise than that, I don't get it.
> 


Yes, I believe your patch is fine.

In fact many drivers dont account the error in their stats.

Thanks
