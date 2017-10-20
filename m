From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 6/8] tools: bpftool: print all relevant byte
 opcodes for "load double word"
Date: Fri, 20 Oct 2017 12:56:39 +0200
Message-ID: <59E9D667.10802@iogearbox.net>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com> <20171019224626.31608-7-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49979 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752834AbdJTK4l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 06:56:41 -0400
In-Reply-To: <20171019224626.31608-7-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2017 12:46 AM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> The eBPF instruction permitting to load double words (8 bytes) into a
> register need 8-byte long "immediate" field, and thus occupy twice the
> space of other instructions. bpftool was aware of this and would
> increment the instruction counter only once on meeting such instruction,
> but it would only print the first four bytes of the immediate value to
> load. Make it able to dump the whole 16 byte-long double instruction
> instead (as would `llvm-objdump -d <program>`).
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
