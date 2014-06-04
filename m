From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] net: remove some useless list_del()
Date: Tue, 03 Jun 2014 17:43:01 -0700
Message-ID: <1401842581.3645.241.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:47457 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754710AbaFDAnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 20:43:03 -0400
Received: by mail-pd0-f171.google.com with SMTP id y13so5337981pdi.30
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 17:43:03 -0700 (PDT)
In-Reply-To: <1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-03 at 17:11 -0700, Cong Wang wrote:
> "list_kill" is allocated on stack and it's a list head,
> it is pointless to call list_del(&kill_list) especially
> after unregister_netdevice_many().

How pointless exactly ? Explain more please.

I suggest you read various commits adding these list_del()

f87e6f47933e3ebeced9bb12615e830a72cedce4 is a good start.
