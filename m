From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Tue, 7 Jan 2014 08:42:22 -0800
Message-ID: <CAPshTCgO3w8t4AY-6nb=8SGj5GfqMwbyeQe27RezzO1fKGR3TQ@mail.gmail.com>
References: <1388896679-23152-1-git-send-email-hkchu@google.com>
	<20140106.154330.1324356005311602000.davem@davemloft.net>
	<20140106.161846.332183513263839789.davem@davemloft.net>
	<1389044441.26646.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:33148 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbaAGQmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 11:42:23 -0500
Received: by mail-qc0-f174.google.com with SMTP id n7so360260qcx.19
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 08:42:23 -0800 (PST)
In-Reply-To: <1389044441.26646.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 7, 2014 at 5:40 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-01-06 at 16:18 -0500, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Mon, 06 Jan 2014 15:43:30 -0500 (EST)
>>
>> > That the gre offload bits won't be registered unless GRE is enabled and
>> > initialized/loaded, right?
>>
>> In fact, it's utterly and completely bogus to make only this change.
>> It breaks the build, I'm reverting:
>>
>> ERROR: "gre_offload_exit" [net/ipv4/gre.ko] undefined!
>> ERROR: "gre_offload_init" [net/ipv4/gre.ko] undefined!
>> --
>
> Jerry, I'll send the patch to do this preparatory work in a small
> and tested unit in the following hour.

Thanks and sorry for breaking the build :(. I knew it was a bad idea
to make a last minute change, especially on something I don't fully
understand, and I did not remember/fully understand all the details/
implication of the two lines in net/ipv4/Makefile:

gre-y := gre_demux.o gre_offload.o
obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o

Will resubmit the GRE-GRO patch shortly.

Best,

Jerry

>
> Thanks.
>
>
