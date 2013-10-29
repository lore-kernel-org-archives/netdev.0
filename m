From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in skb_segment: fskb->len != len
Date: Tue, 29 Oct 2013 05:57:08 -0700
Message-ID: <1383051428.5464.22.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131028115552.GC4408@cpaasch-mac>
	 <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029090849.GC5944@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:39575 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757Ab3J2M5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 08:57:10 -0400
Received: by mail-pd0-f169.google.com with SMTP id q10so8554195pdj.28
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 05:57:09 -0700 (PDT)
In-Reply-To: <20131029090849.GC5944@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 10:08 +0100, Christoph Paasch wrote:
> Ok, my router does not crash anymore with my workload.
> 
> Thanks for fixing it!
> 
> Tested-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Ok fine ;)

Do you mind to test the official patch, as I added a new sysctl so that
GRO layer do not use frag_list on a router ?

You could check that /proc/sys/net/core/gro_frag_list_enable is
automatically cleared.

This way, we have optimal behavior for host or router.

Thanks !
