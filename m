From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bnxt: do not busy-poll when link is down
Date: Tue, 22 Nov 2016 11:06:10 -0800
Message-ID: <1479841570.8455.443.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479838448-44877-1-git-send-email-gospo@broadcom.com>
         <1479839916.8455.439.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACKFLik9rvPfSh1ppcTtjS-bbgsOh4hKJCEaXkCN46eb5_fhpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@broadcom.com>,
        Netdev <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35449 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755713AbcKVTGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 14:06:20 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so2832822pga.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 11:06:12 -0800 (PST)
In-Reply-To: <CACKFLik9rvPfSh1ppcTtjS-bbgsOh4hKJCEaXkCN46eb5_fhpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-22 at 10:55 -0800, Michael Chan wrote:
> On Tue, Nov 22, 2016 at 10:38 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> >
> > Any plans removing this busy polling stuff, now it is done in core
> > networking stack ?
> >
> > This would remove bnxt_lock_napi() extra overhead in normal path ( napi
> > poll )
> >
> > I could do this but I do not have the hardware to do the tests.
> >
> It's on my list of many TODO things.  Probably in the next few weeks.

Awesome, thanks !
