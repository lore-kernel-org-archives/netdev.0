From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] tools: bpf_jit_disasm: Add option to dump JIT image to
 a file.
Date: Tue, 11 Apr 2017 23:54:19 +0200
Message-ID: <58ED508B.9010005@iogearbox.net>
References: <20170411213052.7337-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48087 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752436AbdDKVy0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 17:54:26 -0400
In-Reply-To: <20170411213052.7337-1-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2017 11:30 PM, David Daney wrote:
> When debugging the JIT on an embedded platform or cross build
> environment, libbfd may not be available, making it impossible to run
> bpf_jit_disasm natively.
>
> Add an option to emit a binary image of the JIT code to a file.  This
> file can then be disassembled off line.  Typical usage in this case
> might be (pasting mips64 dmesg output to cat command):
>
>     $ cat > jit.raw
>     $ bpf_jit_disasm -f jit.raw -O jit.bin
>     $ mips64-linux-gnu-objdump -D -b binary -m mips:isa64r2 -EB jit.bin
>
> Signed-off-by: David Daney <david.daney@cavium.com>

Seems good, we could at some point also add an -I jit.bin option
if needed for offline analysis/comparison instead of using -f
plain text.

Thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
