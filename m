From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Fri, 27 Jul 2012 00:19:11 +0200
Message-ID: <1343341151.2626.12094.camel@edumazet-glaptop>
References: <1343324633.2626.11801.camel@edumazet-glaptop>
	 <1343324896.2626.11808.camel@edumazet-glaptop>
	 <CAKgT0UfZmK=gSSn+1Z8=KpW9ckVAJJgQg1+5NdO9SKfWv8GiCg@mail.gmail.com>
	 <20120726.140601.1137230112117936793.davem@davemloft.net>
	 <CAKgT0Ue4mRUpEmKA7SNpTv8D7BKcxYQ65PGoOUkxB27sLuT1Rw@mail.gmail.com>
	 <20120726151312.2f3d9e02@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:36263 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712Ab2GZWTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 18:19:16 -0400
Received: by wgbdr13 with SMTP id dr13so2214195wgb.1
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 15:19:15 -0700 (PDT)
In-Reply-To: <20120726151312.2f3d9e02@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-26 at 15:13 -0700, Stephen Hemminger wrote:

> The fib trie stats are global, you may want to either disable CONFIG_IP_FIB_TRIE_STATS
> or convert them to per-cpu.

I guess its already disabled in Alex case ;)
