From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 3/5] sock_diag: allow to dump bpf filters
Date: Thu, 25 Apr 2013 06:51:17 -0700
Message-ID: <1366897877.8964.133.camel@edumazet-glaptop>
References: <51779426.7020800@6wind.com>
	  <1366818756-4234-1-git-send-email-nicolas.dichtel@6wind.com>
	  <1366818756-4234-4-git-send-email-nicolas.dichtel@6wind.com>
	 <1366820565.8964.78.camel@edumazet-glaptop> <5178EB2C.6070709@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:34220 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756171Ab3DYNvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 09:51:20 -0400
Received: by mail-pb0-f42.google.com with SMTP id up7so798594pbc.29
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 06:51:20 -0700 (PDT)
In-Reply-To: <5178EB2C.6070709@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 10:37 +0200, Nicolas Dichtel wrote:
> I agree. But then you just have to avoid loading the module packet_diag. This 
> module already give some clue to users, because it sends the socket pointer 
> through netlink.

You probably missed a lot of discussion about this socket pointer being
leaked. Supposedly security guys wanted to remove this at one point.

Thats why we should make sure to add yet another security issue.
