From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB going crazy over ~5Gbit/s (4.12.9, but problem present in
 older kernels as well)
Date: Wed, 13 Sep 2017 08:51:43 -0700
Message-ID: <1505317903.15310.167.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4cd23914d8cc2cf5caf78cb5654fb245@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:48252 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751599AbdIMPvq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 11:51:46 -0400
Received: by mail-pg0-f47.google.com with SMTP id v66so1114217pgb.5
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 08:51:45 -0700 (PDT)
In-Reply-To: <4cd23914d8cc2cf5caf78cb5654fb245@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-13 at 18:20 +0300, Denys Fedoryshchenko wrote:
> Hi,
> 
> I noticed after increasing bandwidth over some amount HTB started to 
> throttle classes it should not throttle.
> Also estimated rate in htb totally wrong, while byte counters is 
> correct.
> 
> Is there any overflow or something?

Thanks Denys for the report, I will take a look at this, since I
probably introduced some regression.
