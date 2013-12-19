From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [net-next/master PATCH] lib: fix compile warning in hashlib_init
Date: Thu, 19 Dec 2013 09:15:06 +0800
Message-ID: <20131219011506.GA27326@localhost>
References: <1387415314-21786-1-git-send-email-gaowanlong@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ffusco@redhat.com, kbuild-all@01.org,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1387415314-21786-1-git-send-email-gaowanlong@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC the list.

On Thu, Dec 19, 2013 at 09:08:34AM +0800, Wanlong Gao wrote:
> /git/linux/lib/hash.c: In function 'hashlib_init':
> /git/linux/lib/hash.c:35:2: warning: passing argument 1 of 'setup_arch_fast_hash' from incompatible pointer type [enabled by default]
> /git/linux/include/asm-generic/hash.h:5:20: note: expected 'struct arch_hash_ops *' but argument is of type 'struct fast_hash_ops *'
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> ---
>  include/asm-generic/hash.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/asm-generic/hash.h b/include/asm-generic/hash.h
> index 05cb342..b631284 100644
> --- a/include/asm-generic/hash.h
> +++ b/include/asm-generic/hash.h
> @@ -1,8 +1,8 @@
>  #ifndef __ASM_GENERIC_HASH_H
>  #define __ASM_GENERIC_HASH_H
>  
> -struct arch_hash_ops;
> -static inline void setup_arch_fast_hash(struct arch_hash_ops *ops)
> +struct fast_hash_ops;
> +static inline void setup_arch_fast_hash(struct fast_hash_ops *ops)
>  {
>  }
>  
> -- 
> 1.8.5.2.192.g7794a68
