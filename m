From: Teco Boot <teco@inf-net.nl>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Tue, 13 Aug 2013 10:02:08 +0200
Message-ID: <190D21D2-F86E-46D2-93E8-3050F57FE622@inf-net.nl>
References: <20130807003431.GD16410@order.stressinduktion.org> <EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl> <20130807200637.GD32257@order.stressinduktion.org> <26D8997F-7CDF-425A-B0DC-4D57996871E5@inf-net.nl> <20130809141939.GL14001@order.stressinduktion.org> <CF3AE072-7B80-4C35-9236-4523EE11629F@inf-net.nl> <20130809145743.GM14001@order.stressinduktion.org> <2A0809D4-EBF1-4646-9564-2B7F54956B41@inf-net.nl> <20130810120348.GP14001@order.stressinduktion.org>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:55576 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929Ab3HMICM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 04:02:12 -0400
Received: by mail-wg0-f41.google.com with SMTP id l18so2359180wgh.2
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 01:02:10 -0700 (PDT)
In-Reply-To: <20130810120348.GP14001@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Was it to later to include in 3.11-rc5?
For me, this fix is important. I would like to so this patch in [all|recent] stable kernels quite soon. It is  an important element in my work for v6 multi-homed networks (IETF Homenet WG).
Thanks, Teco

Op 10 aug. 2013, om 14:03 heeft Hannes Frederic Sowa <hannes@stressinduktion.org> het volgende geschreven:

> On Sat, Aug 10, 2013 at 01:39:12PM +0200, Teco Boot wrote:
>> OK, I went back to kernel where I had the ipv6 sadr lookup in cache problem.
>> There I patched the ip6_fib.c.
>> Patch works !!
>> 
>> The hang problem in 3.8.0-28 has lower priority for me. Maybe I'll check current -net-next later. Don't hold your breath.
>> 
>> Now this patch should go mainline and older kernels, I think.
>> What is the next step?
> 
> That already happend. Patch is queued up for inclusion in 3.11 and is sitting
> in the stable queue:
> <http://patchwork.ozlabs.org/bundle/davem/stable/?state=*>
> 
> Thanks for testing,
> 
>  Hannes
> 
