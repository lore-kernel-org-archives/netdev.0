From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH 00/12] at91_ether cleanup
Date: Sat, 20 Oct 2012 14:40:00 +0200
Message-ID: <CAGhQ9Vz9q_r_qUuaSnjEn+zkDWgvW4aOBNiLXF8RfLA0ytrOPQ@mail.gmail.com>
References: <1350594079-4337-1-git-send-email-manabian@gmail.com>
	<20121019.134832.1221504804550166119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:44617 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932168Ab2JTMkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 08:40:02 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so804345lag.19
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 05:40:00 -0700 (PDT)
In-Reply-To: <20121019.134832.1221504804550166119.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 7:48 PM, David Miller <davem@davemloft.net> wrote:
> From: Joachim Eastwood <manabian@gmail.com>
> Date: Thu, 18 Oct 2012 23:01:05 +0200
>
>> This patch series prepares the old at91_ether driver for code
>> sharing with the macb driver. The hardware is similar except for DMA
>> TX/RX, so its not quite clear if it is practical to support both in
>> one driver. But stuff like MDIO and statistics should be possible to
>> share.
>
> All applied, thanks.
>
> Can you get rid of that HAVE_NET_MACB thing?  It's completely
> pointless.  This is a platform driver for crying out loud,
> therefore it can successfully build on any architecture.  And
> we want this exposed for build testing as far as we can.

I'll post a patch series soon which will make all cadence Ethernet
drivers buildable on any architecture.
For macb it will remove the pointless HAVE_NET_MACB and for at91_ether
it will remove the mach include by shuffling some quirk code in a
machine board setup.

regards
Joachim Eastwood
