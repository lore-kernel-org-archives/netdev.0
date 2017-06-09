From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next 2/5] bpf/verifier: rework value tracking
Date: Fri, 09 Jun 2017 15:25:36 +0200
Message-ID: <593AA1D0.3030100@iogearbox.net>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com> <cef78266-62ec-8ef7-a512-cc111ba9c22a@solarflare.com> <20170608023239.lsqijtfcg5fadpai@ast-mbp> <81a661cc-a37c-336b-c10f-1fd4b301ca54@solarflare.com> <20170608164553.y2jvdbmsqqdc7cqt@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexei Starovoitov <ast@fb.com>,
        netdev@vger.kernel.org,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Edward Cree <ecree@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608164553.y2jvdbmsqqdc7cqt@ast-mbp.dhcp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/08/2017 06:45 PM, Alexei Starovoitov wrote:
[...]
> I think Daniel will be happy to test your next rev of the patches.
> I'll test them as well.
> At least 'insn_processed' from C code in tools/testing/selftests/bpf/
> is a good estimate of how these changes affect pruning.

Without having looked more deeply (yet), I ran couple of tests with
the cilium test suite to track complexity. Overall programs load
with the set applied, worst case increase I've seen for some of the
current progs was by ~80% from ~33k to ~60k insns. Will still go over
the code for an initial review either today or tomorrow.

> btw, I'm working on bpf_call support and also refactoring verifier
> quite a bit, but my stuff is far from ready and I'll wait for
> your rewrite to land first.
> One of the things I'm working on is trying to get rid of state pruning
> heuristics and use register+stack liveness information instead.
> It's all experimental so far.

Thanks,
Daniel
