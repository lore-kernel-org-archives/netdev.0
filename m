From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sock: make lockdep_sock_is_held static inline
Date: Thu, 07 Apr 2016 16:08:48 -0700
Message-ID: <1460070528.6473.425.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
	 <1460068227.6473.422.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1460068652.6473.423.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5706E39D.3060206@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34933 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627AbcDGXIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 19:08:51 -0400
Received: by mail-pa0-f50.google.com with SMTP id td3so63063993pab.2
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 16:08:51 -0700 (PDT)
In-Reply-To: <5706E39D.3060206@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-08 at 00:47 +0200, Hannes Frederic Sowa wrote:

> I see... hmpf.
> 
> Wouldn't it be nicer if I include a helper a la:
> 
> #define lockdep_is_held(lock)  1
> 
> in lockdep.h in case lockdep is globally not enabled? I do actually have 
> already another user for this outside of PROVE_RCU.

It probably had been discussed on lkml a long time ago.

My guess is that you can not do that, but am too lazy to tell you why ;)
