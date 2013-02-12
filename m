From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] tcp: fix FIN_WAIT2 timer expression in /proc/net/tcp
Date: Tue, 12 Feb 2013 07:13:22 -0800
Message-ID: <1360682002.13993.3.camel@edumazet-glaptop>
References: <1360673384.10638.10.camel@ubuntu-vm-makita>
	 <1360673521.10638.12.camel@ubuntu-vm-makita>
	 <1360673668.10638.14.camel@ubuntu-vm-makita>
	 <1360681070.13993.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f182.google.com ([209.85.210.182]:65027 "EHLO
	mail-ia0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758195Ab3BLPN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 10:13:26 -0500
Received: by mail-ia0-f182.google.com with SMTP id w33so157524iag.41
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 07:13:25 -0800 (PST)
In-Reply-To: <1360681070.13993.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 06:57 -0800, Eric Dumazet wrote:

> I find this patch confusing :
> 
> 1) Please don't change the indentation for a bug fix
> 
> 2) You add a new 'active=3' field, that some user space
> reading /proc/net/tcp wont expect.
> 
> So the changelog is not matching the changes.

Also, net/ipv4/inet_diag.c was not changed
