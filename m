From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: v4.14-rc3/arm64 DABT exception in atomic_inc() / __skb_clone()
Date: Fri, 20 Oct 2017 16:11:13 +0100
Message-ID: <20171020151112.jz74xr7iz2p2gcna@lakrids.cambridge.arm.com>
References: <EAA60182-6F08-412E-8F8B-FD4B0309A858@gmail.com>
 <20171020111408.edj24tztxdptte5r@lakrids.cambridge.arm.com>
 <960D71EC-C1E9-4898-ACBE-543FC09483FF@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net,
        willemb@google.com, syzkaller@googlegroups.com
To: Wei Wei <dotweiba@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <960D71EC-C1E9-4898-ACBE-543FC09483FF@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 20, 2017 at 10:40:38AM -0400, Wei Wei wrote:
> Sadly, the syzkaller characterized it as a non-reproducible bug and there were empty
>  repro files. But if manually executing in VM like this “./syz-execprog -executor=
> ./syz-executor -repeat=0 -procs=16 -cover=0 crash-log”, it crashed when executing exactly 
> program 1056 using log0 provided.
> 
> I failed to generate the C reproducer with syz-repro as it said “no target compiler”
> in the final step. I would appreciate if you could give some hints.

syz-repro should produce a smaller syzkaller log before it tries to
generate a C file.

I use:

$ syz-repro -config qemu.cfg logN

... and in most cases it will eventually print a smaller log to the
console.

Thanks,
Mark.
