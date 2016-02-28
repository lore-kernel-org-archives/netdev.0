From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 2/3] Support to encoding decoding skb mark
 on IFE action
Date: Sat, 27 Feb 2016 20:25:52 -0800
Message-ID: <CAM_iQpXgi4GPN-bR7_nJZV5gf8iZtzA-pLcieFAyicC=qfSFmw@mail.gmail.com>
References: <1456578536-17732-1-git-send-email-jhs@emojatatu.com>
	<1456578536-17732-3-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:32856 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992703AbcB1EZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 23:25:53 -0500
Received: by mail-yk0-f182.google.com with SMTP id z13so50849321ykd.0
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 20:25:52 -0800 (PST)
In-Reply-To: <1456578536-17732-3-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 27, 2016 at 5:08 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Example usage:
> Set the skb using skbedit then allow it to be encoded
>
> sudo tc qdisc add dev $ETH root handle 1: prio
> sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
> u32 match ip protocol 1 0xff flowid 1:2 \
> action skbedit mark 17 \
> action ife encode \
> allow mark \
> dst 02:15:15:15:15:15
>
> Note: You dont need the skbedit action if you are already encoding the
> skb mark earlier. A zero skb mark, when seen, will not be encoded.
>
> Alternative hard code static mark of 0x12 every time the filter matches
>
> sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 \
> u32 match ip protocol 1 0xff flowid 1:2 \
> action ife encode \
> type 0xDEAD \
> use mark 0x12 \
> dst 02:15:15:15:15:15
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
