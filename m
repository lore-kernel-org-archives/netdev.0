From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: v4.14-rc3/arm64 DABT exception in atomic_inc() / __skb_clone()
Date: Fri, 20 Oct 2017 11:39:35 -0400
Message-ID: <CAF=yD-K76TMjHiYRTRAnxM-x4LBcUDY+27WX477HW6kG=L_aZw@mail.gmail.com>
References: <EAA60182-6F08-412E-8F8B-FD4B0309A858@gmail.com>
 <20171020111408.edj24tztxdptte5r@lakrids.cambridge.arm.com>
 <960D71EC-C1E9-4898-ACBE-543FC09483FF@gmail.com> <CACT4Y+bjzzCv3LSxK12C1xB8GfR3UYCrX_5phRYJ8fpxh9vcvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Wei Wei <dotweiba@gmail.com>, Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:45772 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751694AbdJTPkQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 11:40:16 -0400
In-Reply-To: <CACT4Y+bjzzCv3LSxK12C1xB8GfR3UYCrX_5phRYJ8fpxh9vcvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 11:14 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Fri, Oct 20, 2017 at 4:40 PM, Wei Wei <dotweiba@gmail.com> wrote:
>> Sadly, the syzkaller characterized it as a non-reproducible bug and ther=
e were empty
>>  repro files. But if manually executing in VM like this =E2=80=9C./syz-e=
xecprog -executor=3D
>> ./syz-executor -repeat=3D0 -procs=3D16 -cover=3D0 crash-log=E2=80=9D, it=
 crashed when executing exactly
>> program 1056 using log0 provided.
>>
>> I failed to generate the C reproducer with syz-repro as it said =E2=80=
=9Cno target compiler=E2=80=9D
>> in the final step. I would appreciate if you could give some hints.
>
> syzkaller tries to use aarch64-linux-gnu-gcc when cross-compiling to arm6=
4:
> https://github.com/google/syzkaller/blob/master/sys/targets/targets.go#L6=
2
> Try to install g++-aarch64-linux-gnu.
> Or how should it be done on your system?

A core dump would also be helpful to root around in and inspect
what those registers point to. Thanks for posting the various reports
on github, btw.
