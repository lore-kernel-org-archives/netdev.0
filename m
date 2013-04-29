From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][net-next] gianfar: Fix reported sent bytes to BQL for
 Tx timestamping
Date: Mon, 29 Apr 2013 08:42:45 -0700
Message-ID: <1367250165.8964.319.camel@edumazet-glaptop>
References: <1367240268-32609-1-git-send-email-claudiu.manoil@freescale.com>
	 <1367243593.8964.306.camel@edumazet-glaptop>
	 <517E8354.1010503@freescale.com>
	 <1367249009.8964.312.camel@edumazet-glaptop>
	 <1367249315.8964.314.camel@edumazet-glaptop>
	 <1367249990.8964.317.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:65246 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757386Ab3D2Pms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 11:42:48 -0400
Received: by mail-pd0-f172.google.com with SMTP id 4so3695945pdd.17
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 08:42:48 -0700 (PDT)
In-Reply-To: <1367249990.8964.317.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 08:39 -0700, Eric Dumazet wrote:

> +	*(unsigned int)skb->cb = len;

Obviously not compiled (I am in a bus right now and this driver doesnt
compile on x86_64)

*(unsigned int *)skb->cb = len;
