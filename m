From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [i40e] regression on TCP stream and TCP maerts, kernel-4.12.0-0.rc2
Date: Tue, 30 May 2017 18:27:43 -0700
Message-ID: <CAKgT0Ufb41o=WM=3DM9cwvrw9N5AFn-uL0p1gQB-m+D3BX3DKA@mail.gmail.com>
References: <655ed9ab-853e-7497-9ea3-cc8d13f56043@redhat.com> <CAKgT0UcdJQWqr_zxxi36a6_3iMwBNow-YS723i7t6xsKvAqvCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Netdev <netdev@vger.kernel.org>,
        Adrian Tomasov <atomasov@redhat.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Otto Sabart <osabart@redhat.com>,
        Jirka Hladky <jhladky@redhat.com>
To: Adam Okuliar <aokuliar@redhat.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34625 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750824AbdEaB1o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 21:27:44 -0400
Received: by mail-qt0-f195.google.com with SMTP id l39so332965qtb.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 18:27:44 -0700 (PDT)
In-Reply-To: <CAKgT0UcdJQWqr_zxxi36a6_3iMwBNow-YS723i7t6xsKvAqvCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 30, 2017 at 8:41 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Tue, May 30, 2017 at 6:43 AM, Adam Okuliar <aokuliar@redhat.com> wrote=
:
>> Hello,
>>
>> we found regression on intel card(XL710) with i40e driver. Regression is
>> about ~45%
>> on TCP_STREAM and TCP_MAERTS test for IPv4 and IPv6. Regression was firs=
t
>> visible in kernel-4.12.0-0.rc1.
>>
>> More details about results you can see in uploaded images in bugzilla. [=
0]
>>
>>
>> [0] https://bugzilla.kernel.org/show_bug.cgi?id=3D195923
>>
>>
>> Best regards, / S pozdravom,
>>
>> Adri=C3=A1n Toma=C5=A1ov
>> Kernel Performance QE
>> atomasov@redhat.com
>
> I have added the i40e driver maintainer and the intel-wired-lan
> mailing list so that we can make are developers aware of the issue.
>
> Thanks.
>
> - Alex

Adam,

We are having some issues trying to reproduce what you reported.

Can you provide some additional data. Specifically we would be looking
for an "ethtool -i", and an "ethtool -S" for the port before and after
the test. If you can attach it to the bugzilla that would be
appreciated.

Thanks.

- Alex
