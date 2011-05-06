From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 BONUS 4/3] ipv4: Store rtable entries directly in FIB
Date: Fri, 06 May 2011 10:57:14 -0700 (PDT)
Message-ID: <20110506.105714.193719418.davem@davemloft.net>
References: <20110505.163614.212671515.davem@davemloft.net>
	<alpine.LFD.2.00.1105060944230.1435@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, jpirko@redhat.com,
	herbert@gondor.hengli.com.au, eric.dumazet@gmail.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60342
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751096Ab1EFR5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 13:57:46 -0400
In-Reply-To: <alpine.LFD.2.00.1105060944230.1435@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Fri, 6 May 2011 12:12:26 +0300 (EEST)

> 	Caching results of __mkroute_output in NH does
> not work well for RTN_MULTICAST because ip_check_mc_rcu
> wants to further restrict local delivery depending on
> the source address and protocol.

I understand that multicast needs special handling.

I'm concentrating on unicast/broadcast at the moment because
there is a predominantly clear path for making that work.
