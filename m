From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: fix kfree static array pointer in ipv4_sysctl_exit_net
Date: Thu, 8 May 2014 11:20:32 -0700
Message-ID: <CAL4Wiirje=CB6d4_9gnB3P_q1oOQPJVrrdq3zZ+vnPn7C2PLhA@mail.gmail.com>
References: <536B34FD.8030601@huawei.com>
	<1399552485.7973.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<536B7D34.4050104@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:60329 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbaEHSUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 14:20:33 -0400
Received: by mail-oa0-f45.google.com with SMTP id l6so3534840oag.4
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 11:20:32 -0700 (PDT)
In-Reply-To: <536B7D34.4050104@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No.
> I just trigger the similar case on sctp when I do 'rmmod -f sctp'.
> Here I add the init_net case for sctp register sysctl.
>
> Is it better to add BUG_ON(net == &init_net) maybe?
>

The point is : SCTP _can_ be a module, but IPV4 is not.

You cannot rmmod ipv4

Its not because there is a bug in SCTP that you can apply the same
recipe on another layer.
