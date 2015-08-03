From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH 0/6] test_bpf improvements
Date: Mon,  3 Aug 2015 16:02:02 +0200
Message-ID: <1438610528-14245-1-git-send-email-nschichan@freebox.fr>
Cc: Nicolas Schichan <nschichan@freebox.fr>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Please find below the patch series with my latest changes to test_bpf.

The first patch checks for unexpected NULL generated skbs before
running the filter.

The second patch adds fhe possibility for tests to generate fragmented
skbs.

The third patch tests LD_ABS and LD_IND on fragmented skbs.

The fourth patch adds the possibility to restrict the tests being run
by specifying the name/id/range of the test(s) to run via module
parameters.

The fifth patch tests LD_ABS and LD_IND on non fragmented skbs with
various sizes and alignments.

The sixth and final patch checks that the interpreter or JIT correctly
resets A and X to 0.

This serie is against today's net-next tree.

Regards,

Nicolas Schichan (6):
  test_bpf: avoid oopsing the kernel when generate_test_data() fails.
  test_bpf: allow tests to specify an skb fragment.
  test_bpf: test LD_ABS and LD_IND instructions on fragmented skbs.
  test_bpf: allow running of a single test specified as a module
    parameter.
  test_bpf: add more tests for LD_ABS and LD_IND.
  test_bpf: add tests checking that JIT/interpreter sets A and X to 0.

 lib/test_bpf.c | 645 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 644 insertions(+), 1 deletion(-)

-- 
1.9.1
