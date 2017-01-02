From: Neal Cardwell <ncardwell@google.com>
Subject: Re: tcp_bbr: Forcing set of BBR congestion control as default
Date: Mon, 2 Jan 2017 18:16:04 -0500
Message-ID: <CADVnQy=Ofo0CTqTtNRFnnnSPmfAR_rybx=ZLBiUpSiNKT+nARw@mail.gmail.com>
References: <CA+icZUXd8fN5BAZuCna=zpgSJcXivSG1S6cV1eMMJMWwL7RrLA@mail.gmail.com>
 <CADVnQy=q88Hvh2aYnGCpCQH_b5PNwTZr_AWfgU0NnuSs6aatVQ@mail.gmail.com>
 <CA+icZUUxHFDqfEj+DitFFH6P9+P5kOfMLoQpnK1qW+EZ6PmPKQ@mail.gmail.com>
 <CADVnQymyX1G4=1qaegDYfbq89k15NsG-Acw7mTHRc7jo7=xbQw@mail.gmail.com> <CA+icZUVkui7PaeD7JAfdqJZQY2c9goANwi9foFej3=CsZX+SVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:34249 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755374AbdABXQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 18:16:36 -0500
Received: by mail-oi0-f53.google.com with SMTP id 3so309762988oih.1
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 15:16:35 -0800 (PST)
In-Reply-To: <CA+icZUVkui7PaeD7JAfdqJZQY2c9goANwi9foFej3=CsZX+SVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 2, 2017 at 2:30 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> OK, this looks now good.

Great. Glad to hear it!

> Does BBR only work with fq-qdisc best?

Yes. BBR is designed to work with pacing. And so far the "fq" qdisc is
the only qdisc that offers pacing. So BBR currently needs the "fq"
qdisc. In the future, other qdiscs (or even other layers of the stack)
may offer pacing, in which case BBR could use those as well.

> What about fq_codel?

The "fq_codel" qdisc does not implement pacing, so it would not be sufficient.

cheers,
neal
