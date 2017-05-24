From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v3] libertas: Avoid reading past end of buffer
Date: Wed, 24 May 2017 13:44:22 +0000 (UTC)
Message-ID: <20170524134422.7230F60DD9@smtp.codeaurora.org>
References: <20170515212640.GA45443@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Joe Perches <joe@perches.com>,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Daniel Micay <danielmicay@gmail.com>,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170515212640.GA45443@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook@chromium.org> wrote:
> Using memcpy() from a string that is shorter than the length copied means
> the destination buffer is being filled with arbitrary data from the kernel
> rodata segment. Instead, redefine the stat strings to be ETH_GSTRING_LEN
> sizes, like other drivers. This lets us use a single memcpy that does not
> leak rodata contents. Additionally adjust indentation to keep checkpatch.pl
> happy.
> 
> This was found with the future CONFIG_FORTIFY_SOURCE feature.
> 
> Cc: Daniel Micay <danielmicay@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>

Patch applied to wireless-drivers-next.git, thanks.

12e3c0433e8a libertas: Avoid reading past end of buffer

-- 
https://patchwork.kernel.org/patch/9727997/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
