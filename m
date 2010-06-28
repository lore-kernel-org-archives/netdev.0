From: James Courtier-Dutton <james.dutton@gmail.com>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Mon, 28 Jun 2010 11:17:59 +0100
Message-ID: <AANLkTimK4mGdsSq206aqfusXPvnQczbYDlOWSYXAbOQJ@mail.gmail.com>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
	<1277716394.4235.235.camel@edumazet-laptop>
	<5E7CE189-1002-4723-ACB2-D537B71BA5F3@earthlink.net>
	<1277719251.4235.306.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mitchell Erblich <erblichs@earthlink.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40146 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179Ab0F1KSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 06:18:00 -0400
Received: by fxm14 with SMTP id 14so498496fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 03:17:59 -0700 (PDT)
In-Reply-To: <1277719251.4235.306.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 June 2010 11:00, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Problem is we receive a spike of RX network frames (possibly UDP or some
> other RX only trafic), and chip raises an RX fifo overflow _error_
> indication.
>

The cause of the RX overflow is in my case is TCP.
It is reproducible in mythtv.
While watching LiveTV, press "s" for the program guide.
The program guide is implemented into mythtv by a SQL query that
results in a large response.
The kernel is probably not servicing the RX FIFO quickly enough due to
it being busy doing something else. In this case, probably a video
mode switch.

> Some hardware are buggy enough that such error indication is fatal and
> _require_ hardware reset. Thats life. I suspect b44 driver doing a full
> reset is not a random guess from driver author, but to avoid a complete
> NIC lockup.
>

Interesting, which hardware, apart from the b44, is it that "requires"
a hardware reset after a RX FIFO overflow.
Now, it is true that the driver for the b44 is just as bad on windows,
but there the recovery requires a windows reboot!

Kind Regards

James
