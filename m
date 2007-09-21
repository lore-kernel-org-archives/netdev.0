From: "L F" <lfabio.linux@gmail.com>
Subject: Re: e1000 driver and samba
Date: Fri, 21 Sep 2007 10:13:44 -0400
Message-ID: <780b6f780709210713s62f6d51s90eb0a54cda2a3fb@mail.gmail.com>
References: <46F302A8.7040008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Bruce Cole" <bacole@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:43000 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758308AbXIUONq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 10:13:46 -0400
Received: by wa-out-1112.google.com with SMTP id v27so997051wah
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 07:13:45 -0700 (PDT)
In-Reply-To: <46F302A8.7040008@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/20/07, Bruce Cole <bacole@gmail.com> wrote:
> Yes, that *was* the common recommendation.  But recently I narrowed down the
> realtek performance problem most commonly seen with samba (but also applicable
> to other TCP applications), and I also narrowed down the fix as well.
>
> The current fix involves re-kicking the TX queue after it becomes stuck.
> Apparently it becomes stuck due to a contention problem between the driver and
> controller.  I suspect the root problem is the driver isn't properly locking
> the TX queue.  It might be worth checking if the queue locking problem exists
> in other net drivers as well.
Aha. This doesn't seem to be in mr. Romieu's patch above: should it go
in on top of that?
I ask because with the forementioned patch the newer integrated NICs
seem to be recognised correctly and preliminary testing shows no
disconnect issues, but performance is nothing to write home about (one
of these days I'll get into a rant about samba speed vs. ftp speed,
but this is not the time nor place).

> Reference:
> http://www.spinics.net/lists/netdev/msg40384.html

> Bruce Cole

LF
