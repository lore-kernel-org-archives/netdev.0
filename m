From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net 0/2] bpf: fix two bugs
Date: Thu, 22 Jan 2015 17:11:07 -0800
Message-ID: <1421975469-13035-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Holzheu caught two issues (in bpf syscall and in the test).
Fix them. Details in corresponding patches.

Alexei Starovoitov (2):
  bpf: rcu lock must not be held when calling copy_to_user()
  samples: bpf: relax test_maps check

 kernel/bpf/syscall.c    |   25 +++++++++++++++++--------
 samples/bpf/test_maps.c |    4 ++--
 2 files changed, 19 insertions(+), 10 deletions(-)

-- 
1.7.9.5
