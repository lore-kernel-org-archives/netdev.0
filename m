From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC V1 net-next 1/6] net: Add a new socket option for a
 future transmit time.
Date: Mon, 18 Sep 2017 16:50:59 +0200
Message-ID: <20170918145059.lxaxbsfqen43exam@localhost>
References: <cover.1505719061.git.rcochran@linutronix.de>
 <ad6e265b97b66bcdb19b815e6d9092ffbcb461ba.1505719061.git.rcochran@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Andre Guedes <andre.guedes@intel.com>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>,
        Henrik Austad <henrik@austad.us>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
To: Richard Cochran <rcochran@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ad6e265b97b66bcdb19b815e6d9092ffbcb461ba.1505719061.git.rcochran@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2017 at 09:41:16AM +0200, Richard Cochran wrote:
> diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
> index 3c590c7c42c0..55718129ab06 100644
> --- a/arch/powerpc/include/uapi/asm/socket.h
> +++ b/arch/powerpc/include/uapi/asm/socket.h
> @@ -17,4 +17,7 @@
>  
>  #include <asm-generic/socket.h>
>  
> +#define SO_TXTIME		54
> +#define SCM_TXTIME		SO_TXTIME
> +
>  #endif	/* _ASM_POWERPC_SOCKET_H */

This hunk breaks powerpc builds.  Will fix in the next round...

Thanks,
Richard
