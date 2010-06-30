From: James Courtier-Dutton <james.dutton@gmail.com>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Wed, 30 Jun 2010 20:35:55 +0100
Message-ID: <AANLkTikHnPZ_mRxM3sJZltZ94pDA4X_2JULrbNaxxHOJ@mail.gmail.com>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
	<1277716394.4235.235.camel@edumazet-laptop>
	<5E7CE189-1002-4723-ACB2-D537B71BA5F3@earthlink.net>
	<1277719251.4235.306.camel@edumazet-laptop>
	<AANLkTimK4mGdsSq206aqfusXPvnQczbYDlOWSYXAbOQJ@mail.gmail.com>
	<1277723370.4235.388.camel@edumazet-laptop>
	<ED315045-4A5D-4ECA-99C8-06B4714D8FA0@earthlink.net>
	<1277788678.4235.1285.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mitchell Erblich <erblichs@earthlink.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38655 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756726Ab0F3Tf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 15:35:59 -0400
Received: by fxm14 with SMTP id 14so757814fxm.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 12:35:56 -0700 (PDT)
In-Reply-To: <1277788678.4235.1285.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29 June 2010 06:17, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> rx ring buffer is about 200 frames on b44. One single tcp flow should
> fit.
>
> Limit is 511. James, did you try to increase rx ring ?
>
> ethtool -G eth0 rx 511
>

Any value given to that command results in a non operating NIC.
rmmod b44
modprobe b44 fixes that.

I have narrowed down the problem now.
I can now reset the RX fifo after the RFO in less than 20 ms without
the Ethernet Link going down.
When I get a moment, I will post a patch so other people can test it.

Kind Regards

James
