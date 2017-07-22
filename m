From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 master 1/2] bpf: improve error reporting around
 tail calls
Date: Sat, 22 Jul 2017 10:06:37 +0200
Message-ID: <5973078D.4080905@iogearbox.net>
References: <cover.1500663605.git.daniel@iogearbox.net>        <b0bf43dac3babbb1a78fabeeb2a3a069db4f262c.1500663605.git.daniel@iogearbox.net> <20170721162825.0b42e9ba@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36125 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750989AbdGVIGm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 04:06:42 -0400
In-Reply-To: <20170721162825.0b42e9ba@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2017 01:28 AM, Stephen Hemminger wrote:
> On Fri, 21 Jul 2017 21:13:06 +0200
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>> Currently, it's still quite hard to figure out if a prog passed the
>> verifier, but later gets rejected due to different tail call ownership.
>> Figure out whether that is the case and provide appropriate error
>> messages to the user.
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>
> Sorry, dead code. Please fix and resubmit.
>
> bpf.c:356:12: warning: ‘bpf_derive_prog_from_fdinfo’ defined but not used [-Wunused-function]
>   static int bpf_derive_prog_from_fdinfo(int fd, struct bpf_prog_data *prog)

Yeah, v2 coming later today. I didn't compile with !HAVE_ELF,
where it's not in use indeed. Thanks!
