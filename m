From: Quentin Monnet <quentin.monnet@netronome.com>
Subject: Re: [PATCH net-next 6/8] tools: bpftool: print all relevant byte
 opcodes for "load double word"
Date: Fri, 20 Oct 2017 17:41:55 +0100
Message-ID: <CAH3iqT6Dj5x7dnz5_k3r-EQai=5ebn=JHEKMN+jJDm6aGQdqdQ@mail.gmail.com>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com>
 <20171019224626.31608-7-jakub.kicinski@netronome.com> <063D6719AE5E284EB5DD2968C1650D6DD009D515@AcuExch.aculab.com>
 <CAH3iqT5vPnOCEm6wjavbpSyC4Md922Bts3ynxxVCT-1=MWsgKA@mail.gmail.com> <59EA2077.7000901@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Laight <David.Laight@aculab.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:50575 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752300AbdJTQmQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 12:42:16 -0400
Received: by mail-qk0-f173.google.com with SMTP id o187so15031379qke.7
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 09:42:16 -0700 (PDT)
In-Reply-To: <59EA2077.7000901@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20 October 2017 at 17:12, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 10/20/2017 05:50 PM, Quentin Monnet wrote:
> [...]
>>
>> The remaining four bytes are taken from the "immediate" field of the
>> second
>> instruction, which leaves the first four fields (offset, source and
>> destination
>> registers, and in particular opcode) unused. As far as I know, these
>> fields
>> remain at zero, and this makes it the only =E2=80=9Cinstruction=E2=80=9D=
 to have a null
>> code
>> (although I am not sure this is a strict requirement, because I did not
>> find
>> the code in the verifier that would reject a program having a non-null
>> opcode
>> right after a "load double word immediate" instruction).
>
>
> It's in replace_map_fd_with_map_ptr(), invalid insns for the 2nd part
> are rejected there, they have to be otherwise it's not extendable anymore
> from abi pov; check also 'test1* ld_imm64' in the verifier test cases.
>
> Cheers,
> Daniel

Indeed, thanks Daniel!
Quentin
