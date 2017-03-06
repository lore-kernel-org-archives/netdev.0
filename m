From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC PATCH 1/2] af_packet: direct dma for packet ineterface
Date: Mon, 6 Mar 2017 13:28:02 -0800
Message-ID: <CAAsGZS7HF3cvJ5e45tGHRJhU3xJHnSb4jJV8JEG_eKCcV8hEoQ@mail.gmail.com>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
 <20170127213344.14162.59976.stgit@john-Precision-Tower-5810>
 <20170130191607.14d964e4@redhat.com> <588FB57B.1060507@gmail.com>
 <CAF=yD-J_2Y4eX_iG40rKm3tgs_xr2dr-Rw=JL_OsV0TnfOKhhQ@mail.gmail.com> <58916D84.7090706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        bjorn.topel@gmail.com, jasowang@redhat.com, ast@fb.com,
        alexander.duyck@gmail.com, john.r.fastabend@intel.com,
        Network Development <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:35690 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753906AbdCFViT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 16:38:19 -0500
Received: by mail-ua0-f194.google.com with SMTP id u30so7453083uau.2
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 13:37:54 -0800 (PST)
In-Reply-To: <58916D84.7090706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 9:09 PM, John Fastabend
<john.fastabend@gmail.com> wrote:

>> If I understand correctly, the difficulty lies in v3 requiring that the
>> timer "close" the block when the timer expires. That may not be worth
>> implementing, indeed.
>>
>
> Yep that is where I just gave up and decided it wasn't worth it.
>

Without a support for timeout, when a user-space app has to do its own
book-keeping or lets say  - shutdown for maintenance/upgrade, then how
can they(app) unblock from this operation? Because if the link is idle
then the DMA may never happen because there are no frames on the wire.
So is there a way to handle this?

Chetan
