From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 2/3] net sched actions: skbedit add support
 for mod-ing skb pkt_type
Date: Sat, 02 Jul 2016 19:35:49 +0200
Message-ID: <5777FB75.2050407@iogearbox.net>
References: <1467456196-25712-1-git-send-email-jhs@emojatatu.com> <1467456196-25712-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, fw@strlen.de
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46957 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbcGBRf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 13:35:58 -0400
In-Reply-To: <1467456196-25712-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2016 12:43 PM, Jamal Hadi Salim wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
