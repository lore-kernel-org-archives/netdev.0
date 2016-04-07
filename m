From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue
 immediately after it's detached from sk
Date: Thu, 07 Apr 2016 07:51:05 -0700
Message-ID: <1460040665.6473.398.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
	 <1459315520.6473.187.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1459316043.6473.188.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FB6AA7.1080004@huawei.com>
	 <1459345637.6473.205.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5705F759.9020003@huawei.com>
	 <1460024518.6473.389.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Ding Tianhong <dingtianhong@huawei.com>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35775 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756107AbcDGOvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 10:51:07 -0400
Received: by mail-pa0-f41.google.com with SMTP id td3so56291369pab.2
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 07:51:07 -0700 (PDT)
In-Reply-To: <1460024518.6473.389.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-07 at 03:21 -0700, Eric Dumazet wrote:

> Please do not send patches before really understanding the issue you
> have.
> 
> Having a backlog of 12506206 bytes is ridiculous. Dropping packets is
> absolutely fine if this ever happens.
> 
> Something is really wrong on your host, or the sender simply does not
> comply with TCP protocol (not caring of receiver window at all)
> 
> Since you added a trace of truesize, please also trace skb->len
> 

BTW, have you played with /proc/sys/net/ipv4/tcp_adv_win_scale ?
