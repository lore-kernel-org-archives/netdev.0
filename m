From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: sr9700: Use 'SR_' prefix for the common
 register macros
Date: Wed, 04 Feb 2015 13:53:27 -0800 (PST)
Message-ID: <20150204.135327.2016424933291153633.davem@davemloft.net>
References: <54CFE578.7030207@sunrus.com.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gang.chen@sunrus.com.cn
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54CFE578.7030207@sunrus.com.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chen Gang S <gang.chen@sunrus.com.cn>
Date: Tue, 03 Feb 2015 05:00:40 +0800

> The commone register macors (e.g. RSR) is too commont to drivers, it may
> be conflict with the architectures (e.g. xtensa, sh).
> 
> The related warnings (with allmodconfig under xtensa):
> 
>     CC [M]  drivers/net/usb/sr9700.o
>   In file included from drivers/net/usb/sr9700.c:24:0:
>   drivers/net/usb/sr9700.h:65:0: warning: "RSR" redefined
>    #define RSR   0x06
>    ^
>   In file included from ./arch/xtensa/include/asm/bitops.h:22:0,
>                    from include/linux/bitops.h:36,
>                    from include/linux/kernel.h:10,
>                    from include/linux/list.h:8,
>                    from include/linux/module.h:9,
>                    from drivers/net/usb/sr9700.c:13:
>   ./arch/xtensa/include/asm/processor.h:190:0: note: this is the location of the previous definition
>    #define RSR(v,sr) __asm__ __volatile__ ("rsr %0,"__stringify(sr) : "=a"(v));
>    ^
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Applied, thanks.
