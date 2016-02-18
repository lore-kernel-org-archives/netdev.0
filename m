From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net PATCH v3 1/1] net_sched fix: reclassification needs to consider
 ether protocol changes
Date: Thu, 18 Feb 2016 13:43:20 +0100
Message-ID: <56C5BC68.9060705@iogearbox.net>
References: <1455799084-6166-1-git-send-email-jhs@emojatatu.com> <1455799084-6166-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38382 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425371AbcBRMnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 07:43:23 -0500
In-Reply-To: <1455799084-6166-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2016 01:38 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> actions could change the etherproto in particular with ethernet
> tunnelled data. Typically such actions, after peeling the outer header,
> will ask for the packet to be  reclassified. We then need to restart
> the classification with the new proto header.
>
> Example setup used to catch this:
> sudo tc qdisc add dev $ETH ingress
> sudo $TC filter add dev $ETH parent ffff: pref 1 protocol 802.1Q \
> u32 match u32 0 0 flowid 1:1 \
> action  vlan pop reclassify
>
> Fixes: 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}")
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
