From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: rework prog_digest into prog_tag
Date: Fri, 13 Jan 2017 15:34:43 -0800
Message-ID: <20170113233441.GA67532@ast-mbp.thefacebook.com>
References: <384476e29f6a378766c4052187b9b5f840f4030e.1484346362.git.daniel@iogearbox.net>
 <CALCETrUjmscreaadCOn6hSEMBEf83JyhwdVtKj1=fAf3MuiDtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35973 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751350AbdAMXet (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 18:34:49 -0500
Received: by mail-pf0-f193.google.com with SMTP id b22so10159931pfd.3
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 15:34:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrUjmscreaadCOn6hSEMBEf83JyhwdVtKj1=fAf3MuiDtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 03:16:44PM -0800, Andy Lutomirski wrote:
> On Fri, Jan 13, 2017 at 2:38 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> > Commit 7bd509e311f4 ("bpf: add prog_digest and expose it via
> > fdinfo/netlink") was recently discussed, partially due to
> > admittedly suboptimal name of "prog_digest" in combination
> > with sha1 hash usage, thus inevitably and rightfully concerns
> > about its security in terms of collision resistance were
> > raised with regards to use-cases.
> >
> 
> Seems reasonable.  My only question is whether you'd still want to
> switch to SHA-256 just from a code cleanliness perspective.  With
> SHA-256 you can use the easy streaming API I wrote, but with SHA-1
> you're still stuck with the crappy API in lib/, and I'm not
> volunteering to fix up the SHA-1 API.

No. As was stated many times before there are only negatives
in switching to sha256.
