From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAPI complete race backport?
Date: Thu, 16 Mar 2017 16:33:39 -0700
Message-ID: <1489707219.28631.271.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170316.162533.1242265332354542301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35766 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751185AbdCPXdm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 19:33:42 -0400
Received: by mail-pg0-f53.google.com with SMTP id b129so32142956pgc.2
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 16:33:41 -0700 (PDT)
In-Reply-To: <20170316.162533.1242265332354542301.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-16 at 16:25 -0700, David Miller wrote:
> Eric, could you please give me a backport of commit:
> 
> ====================
> From 39e6c8208d7b6fb9d2047850fb3327db567b564b Mon Sep 17 00:00:00 2001
> From: Eric Dumazet <edumazet@google.com>
> Date: Tue, 28 Feb 2017 10:34:50 -0800
> Subject: [PATCH] net: solve a NAPI race
> ====================
> 
> for 4.10 and earlier?
> 
> This is before __napi_complete() is removed, so the empty poll list
> handling in napi_complete_done() needs to be a bit different.
> 
> Thanks!

Sure, I will send a patch by tomorrow I think.

Thanks.
