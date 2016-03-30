From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue immediately
 after it's detached from sk
Date: Wed, 30 Mar 2016 15:56:22 +0300
Message-ID: <56FBCCF6.80203@cogentembedded.com>
References: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: Yang Yingliang <yangyingliang@huawei.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:35001 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbcC3M4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 08:56:25 -0400
Received: by mail-lf0-f53.google.com with SMTP id k79so35480758lfb.2
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 05:56:24 -0700 (PDT)
In-Reply-To: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/30/2016 8:16 AM, Yang Yingliang wrote:

> When task A hold the sk owned in tcp_sendmsg, if lots of packets
> arrive and the packets will be added to backlog queue. The packets
> will be handled in release_sock called from tcp_sendmsg. When the
> sk_backlog is removed from sk, the length will not decrease until
> all the packets in backlog queue are handled. This may leads to the
> new packets be dropped because the lenth is too big. So set the
> lenth to 0 immediately after it's detached from sk.

    Length?

> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
[...]

MBR, Sergei
