From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bna: ethtool: Avoid reading past end of buffer
Date: Mon, 08 May 2017 14:42:15 -0400 (EDT)
Message-ID: <20170508.144215.2146113320361341036.davem@davemloft.net>
References: <20170505223023.GA17972@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@cavium.com,
        sudarsana.kalluru@cavium.com, linux-kernel@vger.kernel.org,
        Dept-GELinuxNICDev@cavium.com, danielmicay@gmail.com
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170505223023.GA17972@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Fri, 5 May 2017 15:30:23 -0700

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
