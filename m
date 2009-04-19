From: Tzungder Lin <tzungder@gmail.com>
Subject: Re: Probably a flaw in Linux rtl8139 driver FYI
Date: Sun, 19 Apr 2009 14:52:43 +0800
Message-ID: <528f811a0904182352h2b0db478rd2d4f2e5aa484ea0@mail.gmail.com>
References: <528f811a0904170008q34b5cde1l810fb22f78eefaf7@mail.gmail.com>
	 <528f811a0904170010w2b2c8b34j698b255331f78765@mail.gmail.com>
	 <528f811a0904180540t15489826n99cf8143fe105463@mail.gmail.com>
	 <49E9CF3C.2090308@cosmosbay.com>
	 <528f811a0904180828i6b414a10p2dda1a7cbb79db87@mail.gmail.com>
	 <49EA2D53.3080504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:11484 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754387AbZDSGwo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2009 02:52:44 -0400
Received: by wa-out-1112.google.com with SMTP id j5so831229wah.21
        for <netdev@vger.kernel.org>; Sat, 18 Apr 2009 23:52:43 -0700 (PDT)
In-Reply-To: <49EA2D53.3080504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Sirs,

Thank you very much.
I will follow it tonight as soon as possible.

Regards
  jonathan


On 4/19/09, Eric Dumazet <dada1@cosmosbay.com> wrote:
> Tzungder Lin a =E9crit :
> > Dear Eric,
> >
> > I agree with you at first.
> > But after I checked the driver code, I think tp->cur_rx has been se=
t
> > to zero in rtl8139_init_ring() which has been executed before
> > rtl8139_hw_start().
> > So, it should be safe already.
> > Thanks for your advice still.
> > FYR
>
> Very good ! Could you formally post the patch with your Signoff,
> and make it applicable with "patch -p1" ?
>
> (Please read Documentation/SubmittingPatches if you need some info)
>
> Thanks
>
>
>
