From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net-next v4 af-packet 0/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Fri, 19 Aug 2011 10:12:39 -0400
Message-ID: <CAAsGZS4J7i8cvHuGH9AFFwzub+nL-6D0JQzGALCHUkk3K7dDxQ@mail.gmail.com>
References: <1313116260-1000-1-git-send-email-loke.chetan@gmail.com>
	<20110819.033311.1204611705865122620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:65292 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab1HSOMk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 10:12:40 -0400
Received: by pzk37 with SMTP id 37so4904068pzk.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 07:12:39 -0700 (PDT)
In-Reply-To: <20110819.033311.1204611705865122620.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2011 at 6:33 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Chetan Loke <loke.chetan@gmail.com>
> Date: Thu, 11 Aug 2011 22:30:58 -0400
>
>> This patch attempts to:
>> 1)Improve network capture visibility by increasing packet density
>> 2)Assist in analyzing multiple(aggregated) capture ports.
>
> Just some general comments before I say something about the actual
> code.
>
> Claiming loss-less, or almost loss-less, packet capture is something
> which is highly dependent upon the hardware and traffic load.

Totally agree. I have added the text in [Patch 2/2], bullet 1.3 -
capture 99% traffic as seen by the kernel. So lossless is relative to
'the traffic processed by the kernel' and not to the (inline)hardware.
But yes, the patch subject itself could be misleading. Not trying to
argue but just wanted to make sure we are all on the same page.


> So I want you to describe this as what it is, an improvement. =C2=A0M=
ore
> specifically it's just a more flexible mmap ring buffer scheme that
> reduces the wastage incurred by the fixed buffer size scheme we
> have currently.
>
Oki. I will change the cover-subject to 'Enhance af-packet to provide
a flexible mmap ring buffer scheme eliminating fixed frame-size
requirement'.

> Next, you need to use a different subject line for the two patches.
> Right now you say the same thing in both, and someone scanning the
> changesets headers will have no idea what is different about one
> change vs. the other.
>
Done.


Chetan Loke
