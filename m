From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: linux-next: manual merge of the trivial tree with the net tree
Date: Fri, 22 Jul 2011 08:42:48 +0200
Message-ID: <20110722064248.GA10763@electric-eye.fr.zoreil.com>
References: <20110722141842.963b38d45ebf8cb5d0a25fcf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Kosina <jkosina@suse.cz>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Phil Carmody <ext-phil.2.carmody@nokia.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110722141842.963b38d45ebf8cb5d0a25fcf@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell <sfr@canb.auug.org.au> :
[...]
> diff --cc drivers/net/r8169.c
> index 40bcb82,6f36306..0000000
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@@ -682,19 -666,8 +682,19 @@@ struct rtl8169_private 
>   	struct rtl8169_counters counters;
>   	u32 saved_wolopts;
>   
>  -	const struct firmware *fw;
>  +	struct rtl_fw {
>  +		const struct firmware *fw;
>  +
>  +#define RTL_VER_SIZE		32
>  +
>  +		char version[RTL_VER_SIZE];
>  +
>  +		struct rtl_fw_phy_action {
>  +			__le32 *code;
>  +			size_t size;
>  +		} phy_action;
>  +	} *rtl_fw;
> - #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN);
> + #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN)

There should not be further conflict in this part of the code until
things get merged with Linus's tree. Do what suits best.

Thanks.

-- 
Ueimor
