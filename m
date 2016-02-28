From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] Support to encoding decoding skb prio
 on IFE action
Date: Sat, 27 Feb 2016 20:26:20 -0800
Message-ID: <CAM_iQpUk_ee9gudqwOsCEKm3s31TFuXPOKjriUcW2E6jw5i4YA@mail.gmail.com>
References: <1456578536-17732-1-git-send-email-jhs@emojatatu.com>
	<1456578536-17732-4-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:35363 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992685AbcB1E0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 23:26:21 -0500
Received: by mail-yk0-f170.google.com with SMTP id r207so51238194ykd.2
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 20:26:21 -0800 (PST)
In-Reply-To: <1456578536-17732-4-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 27, 2016 at 5:08 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>     Example usage:
>     Set the skb priority using skbedit then allow it to be encoded
>
>     sudo tc qdisc add dev $ETH root handle 1: prio
>     sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
>     u32 match ip protocol 1 0xff flowid 1:2 \
>     action skbedit prio 17 \
>     action ife encode \
>     allow prio \
>     dst 02:15:15:15:15:15
>
>     Note: You dont need the skbedit action if you are already encoding the
>     skb priority earlier. A zero skb priority will not be sent
>
>     Alternative hard code static priority of decimal 33 (unlike skbedit)
>     then mark of 0x12 every time the filter matches
>
>     sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 \
>     u32 match ip protocol 1 0xff flowid 1:2 \
>     action ife encode \
>     type 0xDEAD \
>     use prio 33 \
>     use mark 0x12 \
>     dst 02:15:15:15:15:15
>
>     Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
