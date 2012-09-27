From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inetpeer: ensure to set the maximum tokens the first
 time
Date: Thu, 27 Sep 2012 15:34:46 +0200
Message-ID: <1348752886.5093.1282.camel@edumazet-glaptop>
References: <1348749237-3919-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1348750405.5093.1234.camel@edumazet-glaptop>  <506452F3.4090409@6wind.com>
	 <1348752600.5093.1275.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40873 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab2I0Nev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 09:34:51 -0400
Received: by bkcjk13 with SMTP id jk13so1792137bkc.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 06:34:50 -0700 (PDT)
In-Reply-To: <1348752600.5093.1275.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 15:30 +0200, Eric Dumazet wrote:

> So find the right initializer ?
> 
> p->rate_last = jiffies;
> p->rate_tokens = TOKENS_INIT;
> 
> 

Or :

p->rate_last = jiffies - 60*HZ;

since the rates_tokens initial value is protocol/family dependent
