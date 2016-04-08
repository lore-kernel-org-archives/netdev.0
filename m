From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue
 immediately after it's detached from sk
Date: Fri, 08 Apr 2016 07:44:25 -0700
Message-ID: <1460126665.6473.437.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
	 <1459315520.6473.187.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1459316043.6473.188.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FB6AA7.1080004@huawei.com>
	 <1459345637.6473.205.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5705F759.9020003@huawei.com>
	 <1460024518.6473.389.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1460040665.6473.398.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5707939B.2030907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Ding Tianhong <dingtianhong@huawei.com>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34049 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbcDHOo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 10:44:28 -0400
Received: by mail-pf0-f177.google.com with SMTP id c20so77352276pfc.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 07:44:27 -0700 (PDT)
In-Reply-To: <5707939B.2030907@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-08 at 19:18 +0800, Yang Yingliang wrote:

> I expand  tcp_adv_win_scale and tcp_rmem. It has no effect.

Try :

echo -2 >/proc/sys/net/ipv4/tcp_adv_win_scale

And restart your flows.
