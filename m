From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 0/3] reduce verifier memory consumption and add tests
Date: Tue, 28 Oct 2014 15:11:40 -0700
Message-ID: <1414534303-9906-1-git-send-email-ast@plumgrid.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Small set of cleanups:
 - reduce verifier memory consumption
 - add verifier test to check register state propagation and state equivalence
 - add JIT test reduced from recent nmap triggered crash

Alexei Starovoitov (3):
  bpf: reduce verifier memory consumption
  samples: bpf: add a verifier test and summary line
  test: bpf: add a testcase reduced from nmap

 kernel/bpf/verifier.c       |  101 ++++++++++++++++++++++++-------------------
 lib/test_bpf.c              |   43 ++++++++++++++++++
 samples/bpf/test_verifier.c |   46 +++++++++++++++++++-
 3 files changed, 145 insertions(+), 45 deletions(-)

-- 
1.7.9.5
