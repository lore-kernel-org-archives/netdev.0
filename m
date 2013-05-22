From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] bonding: add synchronize_net() after netdev_rx_handler_unregister
Date: Wed, 22 May 2013 22:30:19 +0400
Message-ID: <519D0EBB.4030307@cogentembedded.com>
References: <519C8504.1080906@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
To: dingtianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:53086 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319Ab3EVSaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 14:30:16 -0400
Received: by mail-la0-f48.google.com with SMTP id fs12so2316798lab.21
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 11:30:14 -0700 (PDT)
In-Reply-To: <519C8504.1080906@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 22-05-2013 12:42, dingtianhong wrote:

> commit 00cfec3748 (net: add a synchronize_net() ...) add a synchronize_net()

    Please specify complete summary line of this commit.

> in netdev_rx_handler_unregister() to guarantee the rx_handler  is NULL when
> rx_handler_data is a non NULL in rcu_read_lock().
>
> so the caller should not use netdev_rx_handler_unregister in atomic as it may
> schedule and sleep, the commit fcd99434f

    You forgot to specify the summary line of this commit.

> fix the bug in bond release, but the
> problem is no action to guarantee the rx_handler_data is NULL when bond release,
> so add synchronize_net() and fix it.

> This patch adds more comments to netdev_rx_handler_unregister().

> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

WBR, Sergei
