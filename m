From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: fix upper BPF instruction limit
Date: Wed, 18 Jun 2014 17:05:22 -0700 (PDT)
Message-ID: <20140618.170522.253556263376208566.davem@davemloft.net>
References: <20140618223457.GA31568@www.outflux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ast@plumgrid.com,
	dborkman@redhat.com, edumazet@google.com, chema@google.com,
	netdev@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140618223457.GA31568@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 18 Jun 2014 15:34:57 -0700

> The original checks (via sk_chk_filter) for instruction count uses ">",
> not ">=", so changing this in sk_convert_filter has the potential to break
> existing seccomp filters that used exactly BPF_MAXINSNS many instructions.
> 
> Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied, thanks.
