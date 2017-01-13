From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: rework prog_digest into prog_tag
Date: Sat, 14 Jan 2017 00:41:09 +0100
Message-ID: <58796595.3030904@iogearbox.net>
References: <384476e29f6a378766c4052187b9b5f840f4030e.1484346362.git.daniel@iogearbox.net> <CALCETrUjmscreaadCOn6hSEMBEf83JyhwdVtKj1=fAf3MuiDtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andrew Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51396 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdAMXlQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 18:41:16 -0500
In-Reply-To: <CALCETrUjmscreaadCOn6hSEMBEf83JyhwdVtKj1=fAf3MuiDtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2017 12:16 AM, Andy Lutomirski wrote:
> On Fri, Jan 13, 2017 at 2:38 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> Commit 7bd509e311f4 ("bpf: add prog_digest and expose it via
>> fdinfo/netlink") was recently discussed, partially due to
>> admittedly suboptimal name of "prog_digest" in combination
>> with sha1 hash usage, thus inevitably and rightfully concerns
>> about its security in terms of collision resistance were
>> raised with regards to use-cases.
>
> Seems reasonable.  My only question is whether you'd still want to
> switch to SHA-256 just from a code cleanliness perspective.  With
> SHA-256 you can use the easy streaming API I wrote, but with SHA-1
> you're still stuck with the crappy API in lib/, and I'm not
> volunteering to fix up the SHA-1 API.

We'd need to truncate that in kernel anyway to not get a too long
tag, so given that I'm actually fine with it as-is. I was planning
to submit the code for testing to bpf selftests for net-next once
it's merged back, too.

Thanks,
Daniel
