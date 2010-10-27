From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: fix use after free
Date: Wed, 27 Oct 2010 14:05:35 -0200
Message-ID: <4CC84DCF.1070806@linux.vnet.ibm.com>
References: <1288116213-11801-1-git-send-email-leitao@linux.vnet.ibm.com> <1288118920.2652.4.camel@edumazet-laptop> <1288156867.2652.127.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:57365 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761279Ab0J0QFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 12:05:45 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp05.br.ibm.com (8.14.4/8.13.1) with ESMTP id o9RFwgEj006061
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 13:58:42 -0200
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9RG4adP966838
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 13:04:40 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9RG5Zfl023391
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 14:05:35 -0200
In-Reply-To: <1288156867.2652.127.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [PATCH] ehea: fix use after free
>
> ehea_start_xmit() dereferences skb after its freeing in ehea_xmit3() to
> get vlan tags.
>
> Move the offending block before the potential ehea_xmit3() call.
>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
