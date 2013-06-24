From: Ricardo Landim <ricardolan@gmail.com>
Subject: Re: UDP splice
Date: Mon, 24 Jun 2013 15:08:25 -0300
Message-ID: <CACYKsS4brDSL4gWGV8Aw455qqa-mdhE_=C7pFS-V=qaA7FBa6g@mail.gmail.com>
References: <CACYKsS7pMFNdBxU2raMphKyb1zU7MEbhc=vsD+FdZ5sgFq71NQ@mail.gmail.com>
	<1372088554.1896.3.camel@bwh-desktop.uk.level5networks.com>
	<20130624155154.GD10413@order.stressinduktion.org>
	<1372089776.1896.9.camel@bwh-desktop.uk.level5networks.com>
	<20130624170119.GE10413@order.stressinduktion.org>
	<CACYKsS5uy6nGbtCYit0eNyBSemzimgLrVdUJAgeBmZwDAy7F-A@mail.gmail.com>
	<1372096418.3301.75.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:38797 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab3FXSIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 14:08:25 -0400
Received: by mail-oa0-f41.google.com with SMTP id n10so12251184oag.28
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 11:08:25 -0700 (PDT)
In-Reply-To: <1372096418.3301.75.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Help in zero copy and improve in cost of syscalls.

In my intel xeon(3.3ghz), read udp socket and write udp socket (proxy)
spends ~40000 cycles (~12 us).



2013/6/24 Eric Dumazet <eric.dumazet@gmail.com>:
> On Mon, 2013-06-24 at 14:09 -0300, Ricardo Landim wrote:
>> Useful for UDP proxy, mainly for RTP payload including voice (voip)
>> and video live stream...
>
>
> I really doubt splice could help voip streams, they usually send one
> small frame every 20 ms. Implementing splice() for such small frame
> would be not really useful.
>
> For video, I would rather use a kernel helper (netfilter/conntrack ?) to
> avoid userland switch...
>
>
>
