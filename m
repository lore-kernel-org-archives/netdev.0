From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC][PATCH 1/4] skbtrace: core feature
Date: Wed, 11 Jul 2012 06:03:18 +0200
Message-ID: <1341979398.3265.6648.camel@edumazet-glaptop>
References: <4FFBC6B6.2000600@gmail.com>  <4FFCE241.6010305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:45535 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab2GKEDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 00:03:23 -0400
Received: by wgbdr13 with SMTP id dr13so610102wgb.1
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 21:03:21 -0700 (PDT)
In-Reply-To: <4FFCE241.6010305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 10:17 +0800, Li Yu wrote:
> From: Li Yu <bingtian.ly@taobao.com>
> 
> This implements core feature of skbtrace, which contains glue code of
> tracepoints subsystem and relay file system, and provide skbtrace API
> for particular networking traces.
> 
> Thanks

Hi Li

This seems a huge amount of code, on an already complex stack.

I am not convinced its needed. It looks like a debugging aid you had to
write in order to understand better linux network stack.

Lets see if you manage to maintain this for a while before considering
upstreaming it.

You said that some 'buggy' drivers set rxhash to zero, but its a valid
operation.

You said 'it seems that RPS hashing can not work well for some corner
cases', but its a known fact.

Thanks
