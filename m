From: Shravan Mishra <shravan.mishra@gmail.com>
Subject: Re:
Date: Wed, 17 Oct 2012 11:18:04 -0400
Message-ID: <CABNhDQzXYRiWRv8MjyMm4zJ0n9OHbykeUnMq-0tuPhmMQ65-8w@mail.gmail.com>
References: <CABNhDQxBMr37chpY_+y_KUh3P1ELDtOERpcn4s=Gy1OMJ2ZHVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:53816 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794Ab2JQPSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 11:18:04 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so11975922iea.19
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 08:18:04 -0700 (PDT)
In-Reply-To: <CABNhDQxBMr37chpY_+y_KUh3P1ELDtOERpcn4s=Gy1OMJ2ZHVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 17, 2012 at 11:16 AM, Shravan Mishra
<shravan.mishra@gmail.com> wrote:
>
> Hi,
>
> Is there a way to simulate delayed acknowlegement such that in my packet
> trace I see it getting triggered.
>
> I'm using 3.2.31 linux kernel.
>
> I don't see any sysctl parameter for doing this.
>
> I checked HZ on my box using sysconf(_SC_CLK_TICK) it shows 100.
>
> Under tcp.h
>
> TCP_DELACK_MIN - HZ/25
>
> which means that my delayed ack timeout will be 40ms.
>
> How can I see this ?
>
> Currently I see tcp acks well within the above bounds.
>
>
> Sincerely
> Shravan
