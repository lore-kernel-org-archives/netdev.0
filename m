From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: Re: [PATCH] tun/tap: Add the missed return value check of
 register_netdevice_notifier
Date: Tue, 25 Jul 2017 10:43:26 +0800
Message-ID: <1EE7E264-429A-4E31-8F9B-B59965940497@gmail.com>
References: <1500543694-23465-1-git-send-email-xiangxia.m.yue@gmail.com>
 <20170724.134509.1200121677424249511.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33444 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752656AbdGYCna (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 22:43:30 -0400
Received: by mail-pf0-f193.google.com with SMTP id k72so8479926pfj.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 19:43:30 -0700 (PDT)
In-Reply-To: <20170724.134509.1200121677424249511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One question, this type bugfix will be applied to net-next ?
> On Jul 25, 2017, at 4:45 AM, David Miller <davem@davemloft.net> wrote:
> 
>> 
>> There is some codes of tun/tap module which did not check the return
>> value of register_netdevice_notifier. Add the check now.
>> 
>> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> 
> Applied.
