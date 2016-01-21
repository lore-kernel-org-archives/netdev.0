From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [PATCH 1/3] net: wireless: rt2x00: Space issue
Date: Thu, 21 Jan 2016 18:04:07 +0100
Message-ID: <CAGXE3d-XH5Efi_9cypT=HmJYzYdzyGoGJxcnrXZ86EVTcDM4Fg@mail.gmail.com>
References: <1445116005-28670-1-git-send-email-paulmcquad@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stanislaw Gruszka <sgruszka@redhat.com>, kvalo@codeaurora.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Paul McQuade <paulmcquad@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445116005-28670-1-git-send-email-paulmcquad@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 17, 2015 at 11:06 PM, Paul McQuade <paulmcquad@gmail.com> wrote:
> Removed empty spaces before/after parenthesis
>
> Signed-off-by: Paul McQuade <paulmcquad@gmail.com>

Looks valid to me as well.

Acked-by: Helmut Schaa <helmut.schaa@googlemail.com>

> ---
>  drivers/net/wireless/rt2x00/rt2x00.h | 24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
> index 3282ddb..6f8310a 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00.h
> +++ b/drivers/net/wireless/rt2x00/rt2x00.h
> @@ -107,7 +107,7 @@
>   * amount of bytes needed to move the data.
>   */
>  #define ALIGN_SIZE(__skb, __header) \
> -       (  ((unsigned long)((__skb)->data + (__header))) & 3 )
> +       (((unsigned long)((__skb)->data + (__header))) & 3)
>
>  /*
>   * Constants for extra TX headroom for alignment purposes.
> @@ -128,14 +128,14 @@
>  #define SLOT_TIME              20
>  #define SHORT_SLOT_TIME                9
>  #define SIFS                   10
> -#define PIFS                   ( SIFS + SLOT_TIME )
> -#define SHORT_PIFS             ( SIFS + SHORT_SLOT_TIME )
> -#define DIFS                   ( PIFS + SLOT_TIME )
> -#define SHORT_DIFS             ( SHORT_PIFS + SHORT_SLOT_TIME )
> -#define EIFS                   ( SIFS + DIFS + \
> -                                 GET_DURATION(IEEE80211_HEADER + ACK_SIZE, 10) )
> -#define SHORT_EIFS             ( SIFS + SHORT_DIFS + \
> -                                 GET_DURATION(IEEE80211_HEADER + ACK_SIZE, 10) )
> +#define PIFS                   (SIFS + SLOT_TIME)
> +#define SHORT_PIFS             (SIFS + SHORT_SLOT_TIME)
> +#define DIFS                   (PIFS + SLOT_TIME)
> +#define SHORT_DIFS             (SHORT_PIFS + SHORT_SLOT_TIME)
> +#define EIFS                   (SIFS + DIFS + \
> +                                 GET_DURATION(IEEE80211_HEADER + ACK_SIZE, 10))
> +#define SHORT_EIFS             (SIFS + SHORT_DIFS + \
> +                                 GET_DURATION(IEEE80211_HEADER + ACK_SIZE, 10))
>
>  enum rt2x00_chip_intf {
>         RT2X00_CHIP_INTF_PCI,
>
> --
> 2.6.1
>
