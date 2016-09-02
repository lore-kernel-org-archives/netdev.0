From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: possible circular locking dependency detected
Date: Fri, 2 Sep 2016 10:12:08 -0700
Message-ID: <CA+55aFz-TaU=C47Rna4b_pibKPfabXWtt88gaqWkUdcN9ay9nQ@mail.gmail.com>
References: <6f7d587b-3933-7c02-a804-db1732ced1cf@stressinduktion.org>
 <CA+55aFyNJg_brA4rGF0S2ve0V_2vuhZCFKEMFDNhHKEXoVCRGA@mail.gmail.com>
 <20160901204746.GR2356@ZenIV.linux.org.uk> <CA+55aFxzRnLCev6i_ehw9LFf-dw3s0znF+nP_c86i=219OZhfg@mail.gmail.com>
 <20160901210142.GS2356@ZenIV.linux.org.uk> <CA+55aFzxJM4pbS_jySERnCoOvvPbo+FgM7FZEATLJnCseD0j0g@mail.gmail.com>
 <CA+55aFwntZpaAutp_C=sLBg8ravfYGRoF4TTG1cfE3SjaJEOtw@mail.gmail.com>
 <87lgzae3f7.fsf@doppelsaurus.mobileactivedefense.com> <20160902160026.GT2356@ZenIV.linux.org.uk>
 <87d1kme10a.fsf@doppelsaurus.mobileactivedefense.com> <20160902170256.GU2356@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rainer Weikusat <rweikusat@cyberadapt.com>,
        CAI Qian <caiqian@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Sandeen <esandeen@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:35969 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932236AbcIBRMK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 13:12:10 -0400
Received: by mail-oi0-f49.google.com with SMTP id r205so90675412oih.3
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 10:12:09 -0700 (PDT)
In-Reply-To: <20160902170256.GU2356@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2016 at 10:02 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> It's very much _not_ just overlayfs being pathological - that it certainly is,
> but the problem is much wider.

Al, can you take a look at my two patches, and see if you agree that
they fix it, though?

Of course, we now have *another* splice deadlock. That pipe inode is
nasty, it's very easy to deadlock on it in subtle ways.

             Linus
