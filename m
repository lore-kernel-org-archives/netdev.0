From: Sumit Semwal <sumit.semwal@linaro.org>
Subject: Re: latest kselftest with stable tree: bpf failures
Date: Thu, 3 Aug 2017 21:04:24 +0530
Message-ID: <CAO_48GHFSa4bkfvEsukJ5snc5F8cXjhp+K9CcZDxOijD-Jo0Ag@mail.gmail.com>
References: <CAO_48GFVH_ciiJRuse55hp2sARYDd0hGncfRembnBCYd_re0JQ@mail.gmail.com>
 <59833EF2.2040203@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: ast@kernel.org, netdev@vger.kernel.org,
        "# 3.4.x" <stable@vger.kernel.org>,
        "open list:KERNEL SELFTEST FRAMEWORK <linux-kselftest@vger.kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Shuah Khan"
        <shuah@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:34235 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751010AbdHCPeq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:34:46 -0400
Received: by mail-wr0-f182.google.com with SMTP id 12so7191246wrb.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:34:46 -0700 (PDT)
In-Reply-To: <59833EF2.2040203@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On 3 August 2017 at 20:49, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Hi Sumit,
>
> On 08/03/2017 05:09 PM, Sumit Semwal wrote:
>>
>> Hello Alexei, Daniel, and the bpf community,
>>
>> As part of trying to improve stable kernels' testing, we're running
>> ~current kselftests with stable kernels (4.4 and 4.9 for now), and
>> reporting issues.
>
>
> Thanks for the report, I haven't been tracking the BPF testsuite
> with stable kernels much so far. I will take a look! Just to clarify,
> with '~current kselftests' you mean the one in current Linus' tree
> or the ones corresponding to the 4.4 and 4.9 -stable kernels?
I meant current Linus's release (4.12) atm.

>
> Thanks,
> Daniel
>
Best,
Sumit.
>
>> While doing this, we see some failures in the bpf tests - most of them
>> look like they are due to trying to test missing features.
>>
>> In Greg's opinion (and mine too :) ), when tests can't find the
>> feature they're trying to test, they should 'degrade gracefully', eg
>> perhaps SKIP instead of FAIL( or core dumps).
>>
>> As you guys are the experts in BPF, may I request someone from this
>> community to look at how can it be achieved with bpf tests?
>>
>> Appreciate the help!
>>
>> Best regards,
>> Sumit.
>>
>



--=20
Thanks and regards,

Sumit Semwal
Linaro Mobile Group - Kernel Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
