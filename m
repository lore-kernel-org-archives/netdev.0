From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 03 Apr 2017 15:14:12 +0200
Message-ID: <58E24AA4.9080204@iogearbox.net>
References: <20170403120748.2d11f2b0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Martin KaFai Lau <kafai@fb.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170403120748.2d11f2b0@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/03/2017 04:07 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got conflicts in:
>
>    tools/testing/selftests/bpf/Makefile
>    tools/testing/selftests/bpf/test_verifier.c
>
> between commit:
>
>    02ea80b1850e ("bpf: add various verifier test cases for self-tests")
>
> from the net tree and commits:
>
>    6882804c916b ("selftests/bpf: add a test for overlapping packet range checks")
>    fb30d4b71214 ("bpf: Add tests for map-in-map")
>
> from the net-next tree.
>
> I fixed it up (see below - though there are probably more fixups needed)
> and can carry the fix as necessary. This is now fixed as far as
> linux-next is concerned, but any non trivial conflicts should be
> mentioned to your upstream maintainer when your tree is submitted for
> merging.  You may also want to consider cooperating with the maintainer
> of the conflicting tree to minimise any particularly complex conflicts.

Looks fine, thanks Stephen!
