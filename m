From: David Miller <davem@davemloft.net>
Subject: Re: bpf: undefined shift in __bpf_prog_run
Date: Fri, 04 Dec 2015 14:26:51 -0500 (EST)
Message-ID: <20151204.142651.968075964630586979.davem@davemloft.net>
References: <20151204184333.GA42737@ast-mbp.thefacebook.com>
	<CACT4Y+YLV4scGXSFz=G3ACa-WE8VuT5wDGvPBV9D2Q+devxedA@mail.gmail.com>
	<20151204191013.GB45508@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, ast@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, sasha.levin@oracle.com,
	edumazet@google.com, ryabinin.a.a@gmail.com
To: alexei.starovoitov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151204191013.GB45508@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Fri, 4 Dec 2015 11:10:15 -0800

> just don't generate random bpf programs with such shifts.

Agreed, it is exactly the same as if the compiler emitted real cpu
shift instructions with undefined behavior.

The creator of the BPF code in question is what should be fixed.
