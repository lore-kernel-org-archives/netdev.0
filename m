From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next 1/2] tools: psock_lib: tighten conditions
 checked in sock_setfilter
Date: Wed, 04 Jan 2017 23:59:54 +0100
Message-ID: <586D7E6A.5080009@iogearbox.net>
References: <cover.1483555162.git.sowmini.varadhan@oracle.com> <3aa068fa482f7cf5381957e9a3ea58550822d1d1.1483555162.git.sowmini.varadhan@oracle.com> <586D7437.1050708@iogearbox.net> <20170104222224.GA31756@oracle.com> <586D7692.4000604@iogearbox.net> <20170104224848.GB31756@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        willemb@google.com, davem@davemloft.net, shuah@kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48225 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969664AbdADXU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 18:20:27 -0500
In-Reply-To: <20170104224848.GB31756@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 11:48 PM, Sowmini Varadhan wrote:
> On (01/04/17 23:26), Daniel Borkmann wrote:
[...]
>>>> As it stands it makes it a bit harder to parse / less readable with macros
>>>> actually. Rest seems fine, thanks.
>
> Usually macros are there (a) as an abstraction so you
> dont have to hard-code things, and, (b) to make things
> more readable. (maybe that's why the 1992 VJ paper on
> BPF came up with these macros?)
>
> I think we differ on code-aesthetics (not correctness) here.
> It was not immediately obvious to me that "0x15 is actually
> BPF_JMP + BPF_JEQ + BPF_K" etc, when I wanted to extend
> the bpf_prog to harden the checks in the existing code.
>
> Would it be ok to leave the extremely subjective
> "make this more readable" part for you to tackle later?
> Or I can just drop patch1, and you can fix it to your
> satisfaction later.

I think we're talking past each other (?), my suggestion
from my original email was to use bpf_asm and paste the
(human readable) program as a comment above as done also
elsewhere. But just leave it as it is then, no big deal
either.
