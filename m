From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: NAPI requires netif_receive_skb()
Date: Tue, 08 Oct 2013 23:52:13 +0200
Message-ID: <52547E8D.3080101@cogentembedded.com>
References: <201309030303.11381.sergei.shtylyov@cogentembedded.com> <20130904.141252.532474080722830977.davem@davemloft.net> <Pine.LNX.4.64.1309261751200.11968@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:46553 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756609Ab3JHUxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:53:31 -0400
Received: by mail-ee0-f44.google.com with SMTP id b47so4315471eek.3
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 13:53:30 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.1309261751200.11968@axis700.grange>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26-09-2013 18:12, Guennadi Liakhovetski wrote:

>> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> Date: Tue, 3 Sep 2013 03:03:10 +0400

>>> Driver supporting NAPI should use NAPI-specific function for receiving packets,
>>> so netif_rx() should be changed to netif_receive_skb().

>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> This patch breaks NFS boot on Armadillo800eva for me. Network
> communication slows down to a crawl with

> net eth0: Receive FIFO Overflow
> nfs: server 192.168.x.y not responding, still trying

> With this patch reverted (e.g. in today's Linus tree snapshot) boot is
> restored.

    Guennadi, are you expecting some actions (like looking into what Eric have 
suggested) from me? If so, I'm still on vacation, should be back next Tuesday.
    I don't think reverting the patch is a Right Thing to do.

> Thanks
> Guennadi

WBR, Sergei
