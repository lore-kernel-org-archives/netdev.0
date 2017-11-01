From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Wed, 1 Nov 2017 18:10:10 +1100
Message-ID: <20171101181010.7fcceeab@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Yonghong Song <yhs@fb.com>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the tip tree got a conflict in:

  kernel/events/core.c

between commit:

  97562633bcba ("bpf: perf event change needed for subsequent bpf helpers")

from the net-next tree and commits:

  7d9285e82db5 ("perf/bpf: Extend the perf_event_read_local() interface, a.k.a. "bpf: perf event change needed for subsequent bpf helpers"")
  0d3d73aac2ff ("perf/core: Rewrite event timekeeping")

from the tip tree.

I fixed it up (the latter just removed the code added by the two earlier
patches) and can carry the fix as necessary. This is now fixed as far as
linux-next is concerned, but any non trivial conflicts should be mentioned
to your upstream maintainer when your tree is submitted for merging.
You may also want to consider cooperating with the maintainer of the
conflicting tree to minimise any particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell
