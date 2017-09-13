From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB going crazy over ~5Gbit/s (4.12.9, but problem present in
 older kernels as well)
Date: Wed, 13 Sep 2017 09:16:10 -0700
Message-ID: <1505319370.15310.169.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4cd23914d8cc2cf5caf78cb5654fb245@nuclearcat.com>
         <d2aee52fda21d8f668ca012333ef3677@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:46761 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751550AbdIMQQM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 12:16:12 -0400
Received: by mail-pg0-f54.google.com with SMTP id i130so1263750pgc.3
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 09:16:12 -0700 (PDT)
In-Reply-To: <d2aee52fda21d8f668ca012333ef3677@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-13 at 18:34 +0300, Denys Fedoryshchenko wrote:
> Well, probably i am answering my own question, removing estimator from 
> classes seems drastically improve situation.
> It seems estimator has some issues that cause shaper to behave 
> incorrectly (throttling traffic while it should not).
> But i guess thats a bug?
> As i was not able to predict such bottleneck by CPU load measurements.

Well, there was a reason we disabled HTB class estimators by default ;)


https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=64153ce0a7b61b2a5cacb01805cbf670142339e9
