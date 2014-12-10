From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [net: sock] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000007
Date: Wed, 10 Dec 2014 15:51:33 -0800
Message-ID: <CAMEtUuxexMXtvK_R7YZEvx_iyK9mAx_zrqr1bkj3PsUwoq0p5A@mail.gmail.com>
References: <20141210232911.GE24163@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKP <lkp@01.org>, LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141210232911.GE24163@wfg-t540p.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 10, 2014 at 3:29 PM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> Greetings,
>
> 0day kernel testing robot got the below dmesg and the first bad commit is
>
>     net: sock: allow eBPF programs to be attached to sockets

> [init] Kernel was tainted on startup. Will ignore flags that are already set.
> [init] Started watchdog process, PID is 9354
> [main] Main thread is alive.
> [   21.233581] BUG: unable to handle kernel NULL pointer dereference at 0000000000000007
> [   21.234709] IP: [<ffffffff8156ebda>] sk_attach_bpf+0x39/0xc2

thanks for the report! syscall fuzzer is great.
I missed an extra check. Working on a fix.
