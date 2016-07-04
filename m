From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/3] net sched actions: skbedit add support
 for mod-ing skb pkt_type
Date: Mon, 04 Jul 2016 15:11:54 -0700 (PDT)
Message-ID: <20160704.151154.1138773384083862532.davem@davemloft.net>
References: <1467456196-25712-1-git-send-email-jhs@emojatatu.com>
	<1467456196-25712-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, fw@strlen.de
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:50360 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753490AbcGDWLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 18:11:55 -0400
In-Reply-To: <1467456196-25712-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sat,  2 Jul 2016 06:43:15 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Extremely useful for setting packet type to host so i dont
> have to modify the dst mac address using pedit (which requires
> that i know the mac address)
> 
> Example usage:
> tc filter add dev eth0 parent ffff: protocol ip pref 9 u32 \
> match ip src 5.5.5.5/32 \
> flowid 1:5 action skbedit ptype host
> 
> This will tag all packets incoming from 5.5.5.5 with type
> PACKET_HOST
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
