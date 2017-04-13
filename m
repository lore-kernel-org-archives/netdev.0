From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tools: bpf_jit_disasm: Add option to dump JIT image to
 a file.
Date: Thu, 13 Apr 2017 13:04:15 -0400 (EDT)
Message-ID: <20170413.130415.1776516439699504044.davem@davemloft.net>
References: <20170411213052.7337-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: david.daney@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170411213052.7337-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>
Date: Tue, 11 Apr 2017 14:30:52 -0700

> When debugging the JIT on an embedded platform or cross build
> environment, libbfd may not be available, making it impossible to run
> bpf_jit_disasm natively.
> 
> Add an option to emit a binary image of the JIT code to a file.  This
> file can then be disassembled off line.  Typical usage in this case
> might be (pasting mips64 dmesg output to cat command):
> 
>    $ cat > jit.raw
>    $ bpf_jit_disasm -f jit.raw -O jit.bin
>    $ mips64-linux-gnu-objdump -D -b binary -m mips:isa64r2 -EB jit.bin
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Applied, thanks.
