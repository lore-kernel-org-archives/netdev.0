From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next v3 1/3] ipvlan: scrub skb before routing in L3 mode.
Date: Thu, 18 Feb 2016 16:39:36 -0800
Message-ID: <CAF2d9jjPc6pwuZZiuLCc27ex+Hqc9-x0MdyyaR=ErwVV===DEQ@mail.gmail.com>
References: <1455767550-16896-1-git-send-email-mahesh@bandewar.net> <CAM_iQpXUv1s1xw9g9uox25fYrRXpTjFLE5_OwUYE_tCZAoGF3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:34243 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992562AbcBSAj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 19:39:56 -0500
Received: by mail-yw0-f175.google.com with SMTP id h129so55548329ywb.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 16:39:56 -0800 (PST)
In-Reply-To: <CAM_iQpXUv1s1xw9g9uox25fYrRXpTjFLE5_OwUYE_tCZAoGF3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]
>> -       skb_dst_drop(skb);
>> +       skb_scrub_packet(skb, true);
>
> At least this patch is still same with the previous version. Or am I
> missing anything?

 xnet param is now set to 'true'.
