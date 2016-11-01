From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel encapsulation
Date: Tue, 1 Nov 2016 14:05:27 -0700
Message-ID: <CACby=pmnH0kyndLdviy-MLUN5rTYVtEm8YC5n+z1XZdf1SqsRQ@mail.gmail.com>
References: <cover.1477959702.git.tgraf@suug.ch> <CALx6S35BhiY7DVPetEDrLwgsR3sKTcm-bJ6og-6N329Znavkww@mail.gmail.com>
 <CACby=pkPQC92t3Y9-p9RRUv1_WL2uZMM6DRJFUc5-KP4B41hAA@mail.gmail.com>
 <CALx6S34ZVK1uHu_dYyh2w=k+8gP-H-nSPw-OgsMk9D2f4uE7jA@mail.gmail.com>
 <CACby=pnLzihLCFzT-HvB3Ovo-hC1b79Dr6iO74y5mMqPspHFBg@mail.gmail.com>
 <CALx6S35FYAQWk1p_PztBJ_ojio6OOdeYDb-AYQwZ0juxPj5gYQ@mail.gmail.com>
 <CACby=p=pjsSmu8EWWomm-MLE2E+H9BSs9Y2ZAiH2Jh67gScMsw@mail.gmail.com> <CALx6S36o1ig4rhN3MTaD1OCJ3sQo_ghbkonde1JDf4S9X=YkZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        roopa <roopa@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:33291 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752855AbcKAVFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 17:05:34 -0400
Received: by mail-ua0-f181.google.com with SMTP id 20so123212270uak.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 14:05:29 -0700 (PDT)
In-Reply-To: <CALx6S36o1ig4rhN3MTaD1OCJ3sQo_ghbkonde1JDf4S9X=YkZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 November 2016 at 13:33, Tom Herbert <tom@herbertland.com> wrote:
> You need to show that is integrity is maintained with these patches.
> Part of this can be done, but part of this needs to be established in
> testing.
>
> I've already given specifics for at least one potential source of
> issues in routing issues. I would like to know what happens if someone
> rewrites an IPv4 packet into IPv6 packet or vice versa. AFAICT we
> would be send an IPv6 using an IPv4 route, or an IPv4 using an IPv6
> route. What is supposed to happen in these circumstances? What
> actually happens?
>
> Similarly, someone overwrites the whole packet with 0xff. What happens
> when we try to send that?

OK, I will add these tests to the selftest in the next iteration.
