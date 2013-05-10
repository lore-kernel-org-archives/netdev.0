From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [RFC PATCH net-next] sh_eth: add support for r8a7790 SoC
Date: Fri, 10 May 2013 17:35:33 +0900
Message-ID: <CANqRtoQXnxOncf-_JPsVP0MZLTGorywfoJu6Gx9R=TMJYoS3Bw@mail.gmail.com>
References: <1368172891-26381-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1368172891-26381-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Simon,

On Fri, May 10, 2013 at 5:01 PM, Simon Horman
<horms+renesas@verge.net.au> wrote:
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> ---
>  drivers/net/ethernet/renesas/Kconfig  |  2 +-
>  drivers/net/ethernet/renesas/sh_eth.c | 10 ++++++++--
>  drivers/net/ethernet/renesas/sh_eth.h |  1 +
>  3 files changed, 10 insertions(+), 3 deletions(-)

Thanks for your work on this driver.

> diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
> index bed9841..d664c0f 100644
> --- a/drivers/net/ethernet/renesas/Kconfig
> +++ b/drivers/net/ethernet/renesas/Kconfig
> @@ -9,7 +9,7 @@ config SH_ETH
>                  CPU_SUBTYPE_SH7763 || CPU_SUBTYPE_SH7619 || \
>                  CPU_SUBTYPE_SH7724 || CPU_SUBTYPE_SH7734 || \
>                  CPU_SUBTYPE_SH7757 || ARCH_R8A7740 || \
> -                ARCH_R8A7778 || ARCH_R8A7779)
> +                ARCH_R8A7778 || ARCH_R8A7779 || ARCH_R8A7790)

As much as I want to see R8A7790 support right away, wouldn't it be
nice _not_ to have this dependency crap in the Kconfig? We are already
multi-SoC within mach-shmobile ARM and soon we will be multi-subarch.

I actually thought that this was already taken care of. What is your
opinion? Perhaps there are already queued up cleanup patches that
handle this?

Thanks,

/ magnus
