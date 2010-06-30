From: James Courtier-Dutton <james.dutton@gmail.com>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Wed, 30 Jun 2010 23:20:33 +0100
Message-ID: <AANLkTinQSSr2UXtDp7LGBNx1si1QKj5nrJHnm9Z2qDqM@mail.gmail.com>
References: <5E7CE189-1002-4723-ACB2-D537B71BA5F3@earthlink.net>
	<1277719251.4235.306.camel@edumazet-laptop>
	<AANLkTimK4mGdsSq206aqfusXPvnQczbYDlOWSYXAbOQJ@mail.gmail.com>
	<20100630.132220.129754921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eric.dumazet@gmail.com, erblichs@earthlink.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37750 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752754Ab0F3WUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 18:20:35 -0400
Received: by fxm14 with SMTP id 14so818495fxm.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 15:20:33 -0700 (PDT)
In-Reply-To: <20100630.132220.129754921.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30 June 2010 21:22, David Miller <davem@davemloft.net> wrote:
> From: James Courtier-Dutton <james.dutton@gmail.com>
> Date: Mon, 28 Jun 2010 11:17:59 +0100
>
>> Interesting, which hardware, apart from the b44, is it that "requires"
>> a hardware reset after a RX FIFO overflow.
>
> This problem is quite common, actually.
>
> Even though it shouldn't be, this is seemingly one of the least tested
> paths of a networking chip.
>
> You'd think the recovery would be easy, flush the fifos and drop the
> packet, then rewind the RX descriptor pointer.
>
> But it's not and I've seen everything from RX descriptor corruption
> to random DMA splats elsewhere corrupting memory entirely, as a result
> of a networking card taking a RX fifo overflow.
>

Well, I have just written a patch (see other thread) to try and reset
the FIFO instead of a complete HW reset.
How do I know if I have RX descriptor corruption, or random DMA splats?
I have not detected any problems so far.
