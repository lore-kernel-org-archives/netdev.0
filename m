From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] samples/bpf: add bpf map stress test
Date: Tue, 08 Mar 2016 23:22:13 -0500 (EST)
Message-ID: <20160308.232213.1624474136438943765.davem@davemloft.net>
References: <1457478474-1614041-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457478474-1614041-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 8 Mar 2016 15:07:52 -0800

> this test calls bpf programs from different contexts:
> from inside of slub, from rcu, from pretty much everywhere,
> since it kprobes all spin_lock functions.
> It stresses the bpf hash and percpu map pre-allocation,
> deallocation logic and call_rcu mechanisms.
> User space part adding more stress by walking and deleting map elements.
> 
> Note that due to nature bpf_load.c the earlier kprobe+bpf programs are
> already active while loader loads new programs, creates new kprobes and
> attaches them.
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied.
