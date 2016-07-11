From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bpf: make inode code explicitly non-modular
Date: Mon, 11 Jul 2016 13:53:08 -0700 (PDT)
Message-ID: <20160711.135308.1582731215529703059.davem@davemloft.net>
References: <20160711165101.2252-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ast@kernel.org,
	netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160711165101.2252-1-paul.gortmaker@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 11 Jul 2016 12:51:01 -0400

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

Applied.
