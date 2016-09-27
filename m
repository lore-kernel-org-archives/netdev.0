From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] bpf: Set register type according to
 is_valid_access()
Date: Tue, 27 Sep 2016 03:52:01 -0400 (EDT)
Message-ID: <20160927.035201.185206386895576436.davem@davemloft.net>
References: <20160924180150.23620-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, ast@kernel.org, luto@amacapital.net,
        daniel@iogearbox.net, keescook@chromium.org, sargun@sargun.me,
        tj@kernel.org, netdev@vger.kernel.org
To: mic@digikod.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160924180150.23620-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mickaël Salaün <mic@digikod.net>
Date: Sat, 24 Sep 2016 20:01:50 +0200

> This prevent future potential pointer leaks when an unprivileged eBPF
> program will read a pointer value from its context. Even if
> is_valid_access() returns a pointer type, the eBPF verifier replace it
> with UNKNOWN_VALUE. The register value that contains a kernel address is
> then allowed to leak. Moreover, this fix allows unprivileged eBPF
> programs to use functions with (legitimate) pointer arguments.
> 
> Not an issue currently since reg_type is only set for PTR_TO_PACKET or
> PTR_TO_PACKET_END in XDP and TC programs that can only be loaded as
> privileged. For now, the only unprivileged eBPF program allowed is for
> socket filtering and all the types from its context are UNKNOWN_VALUE.
> However, this fix is important for future unprivileged eBPF programs
> which could use pointers in their context.
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>

Applied to net-next, thanks.
