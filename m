From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: Avoid reading past end of buffer
Date: Mon, 08 May 2017 14:42:21 -0400 (EDT)
Message-ID: <20170508.144221.1326034654665240024.davem@davemloft.net>
References: <20170505223434.GA19245@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harish.patil@cavium.com,
        manish.chopra@cavium.com, Dept-GELinuxNICDev@cavium.com,
        linux-kernel@vger.kernel.org, danielmicay@gmail.com
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170505223434.GA19245@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Fri, 5 May 2017 15:34:34 -0700

> Using memcpy() from a string that is shorter than the length copied means
> the destination buffer is being filled with arbitrary data from the kernel
> rodata segment. Instead, use strncpy() which will fill the trailing bytes
> with zeros.
> 
> This was found with the future CONFIG_FORTIFY_SOURCE feature.
> 
> Cc: Daniel Micay <danielmicay@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
