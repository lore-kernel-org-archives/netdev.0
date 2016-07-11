From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH -next] bpf: make inode code explicitly non-modular
Date: Mon, 11 Jul 2016 19:28:48 +0200
Message-ID: <5783D750.8070302@iogearbox.net>
References: <20160711165101.2252-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160711165101.2252-1-paul.gortmaker@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/11/2016 06:51 PM, Paul Gortmaker wrote:
> The Kconfig currently controlling compilation of this code is:
>
> init/Kconfig:config BPF_SYSCALL
> init/Kconfig:   bool "Enable bpf() system call"
>
> ...meaning that it currently is not being built as a module by anyone.
>
> Lets remove the couple traces of modular infrastructure use, so that
> when reading the driver there is no doubt it is builtin-only.
>
> Note that MODULE_ALIAS is a no-op for non-modular code.
>
> We replace module.h with init.h since the file does use __init.
>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

(Patch is for net-next tree then.)

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
