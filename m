From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH wireless-next] wireless: Remove unnecessary ; from while
 (0) macros
Date: Tue, 03 Apr 2012 17:42:29 -0500
Message-ID: <4F7B7CD5.107@lwfinger.net>
References: <1333489609.2695.14.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Roland Vossen <rvossen-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kan Yan <kanyan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1333489609.2695.14.camel@joe2Laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/03/2012 04:46 PM, Joe Perches wrote:
> Semicolons are not necessary after macros that end in while (0).
> Remove them.
>
> Simplify the macros with tests of
> do { if (foo>size) memset1; else memset2;} while (0);
> to a single line memset(,,min_t(size_t, foo, size))
>
> Signed-off-by: Joe Perches<joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

ACKed-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> (rtlwifi part)

> ---
>   drivers/net/wireless/ath/carl9170/cmd.h       |    6 +++---
>   drivers/net/wireless/brcm80211/brcmsmac/d11.h |    2 +-
>   drivers/net/wireless/mwifiex/sdio.h           |    8 ++++----
>   drivers/net/wireless/rtlwifi/rtl8192ce/trx.h  |    7 +------
>   drivers/net/wireless/rtlwifi/rtl8192de/trx.h  |    8 ++------
>   drivers/net/wireless/rtlwifi/rtl8192se/def.h  |    7 +------
>   drivers/net/wireless/rtlwifi/rtl8192se/fw.h   |    6 +++---
>   7 files changed, 15 insertions(+), 29 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/carl9170/cmd.h b/drivers/net/wireless/ath/carl9170/cmd.h
> index 885c427..65919c9 100644
> --- a/drivers/net/wireless/ath/carl9170/cmd.h
> +++ b/drivers/net/wireless/ath/carl9170/cmd.h
> @@ -114,7 +114,7 @@ __regwrite_out :							\
>
>   #define carl9170_regwrite_result()					\
>   	__err;								\
> -} while (0);
> +} while (0)
>
>
>   #define carl9170_async_regwrite_get_buf()				\
> @@ -126,7 +126,7 @@ do {									\
>   		__err = -ENOMEM;					\
>   		goto __async_regwrite_out;				\
>   	}								\
> -} while (0);
> +} while (0)
>
>   #define carl9170_async_regwrite_begin(carl)				\
>   do {									\
> @@ -169,6 +169,6 @@ __async_regwrite_out:							\
>
>   #define carl9170_async_regwrite_result()				\
>   	__err;								\
> -} while (0);
> +} while (0)
>
>   #endif /* __CMD_H */
> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/d11.h b/drivers/net/wireless/brcm80211/brcmsmac/d11.h
> index 1948cb2..3f659e0 100644
> --- a/drivers/net/wireless/brcm80211/brcmsmac/d11.h
> +++ b/drivers/net/wireless/brcm80211/brcmsmac/d11.h
> @@ -733,7 +733,7 @@ struct cck_phy_hdr {
>   	do { \
>   		plcp[1] = len&  0xff; \
>   		plcp[2] = ((len>>  8)&  0xff); \
> -	} while (0);
> +	} while (0)
>
>   #define BRCMS_SET_MIMO_PLCP_AMPDU(plcp) (plcp[3] |= MIMO_PLCP_AMPDU)
>   #define BRCMS_CLR_MIMO_PLCP_AMPDU(plcp) (plcp[3]&= ~MIMO_PLCP_AMPDU)
> diff --git a/drivers/net/wireless/mwifiex/sdio.h b/drivers/net/wireless/mwifiex/sdio.h
> index a3fb322..0ead152 100644
> --- a/drivers/net/wireless/mwifiex/sdio.h
> +++ b/drivers/net/wireless/mwifiex/sdio.h
> @@ -193,7 +193,7 @@
>   		a->mpa_tx.ports |= (1<<(a->mpa_tx.pkt_cnt+1+(MAX_PORT -	\
>   						a->mp_end_port)));	\
>   	a->mpa_tx.pkt_cnt++;						\
> -} while (0);
> +} while (0)
>
>   /* SDIO Tx aggregation limit ? */
>   #define MP_TX_AGGR_PKT_LIMIT_REACHED(a)					\
> @@ -211,7 +211,7 @@
>   	a->mpa_tx.buf_len = 0;						\
>   	a->mpa_tx.ports = 0;						\
>   	a->mpa_tx.start_port = 0;					\
> -} while (0);
> +} while (0)
>
>   /* SDIO Rx aggregation limit ? */
>   #define MP_RX_AGGR_PKT_LIMIT_REACHED(a)					\
> @@ -242,7 +242,7 @@
>   	a->mpa_rx.skb_arr[a->mpa_rx.pkt_cnt] = skb;			\
>   	a->mpa_rx.len_arr[a->mpa_rx.pkt_cnt] = skb->len;		\
>   	a->mpa_rx.pkt_cnt++;						\
> -} while (0);
> +} while (0)
>
>   /* Reset SDIO Rx aggregation buffer parameters */
>   #define MP_RX_AGGR_BUF_RESET(a) do {					\
> @@ -250,7 +250,7 @@
>   	a->mpa_rx.buf_len = 0;						\
>   	a->mpa_rx.ports = 0;						\
>   	a->mpa_rx.start_port = 0;					\
> -} while (0);
> +} while (0)
>
>
>   /* data structure for SDIO MPA TX */
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.h b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.h
> index efb9ab2..c4adb97 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.h
> +++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.h
> @@ -530,12 +530,7 @@
>   	SET_BITS_OFFSET_LE(__pdesc+28, 0, 32, __val)
>
>   #define CLEAR_PCI_TX_DESC_CONTENT(__pdesc, _size)	\
> -do {							\
> -	if (_size>  TX_DESC_NEXT_DESC_OFFSET)		\
> -		memset(__pdesc, 0, TX_DESC_NEXT_DESC_OFFSET);	\
> -	else						\
> -		memset(__pdesc, 0, _size);	\
> -} while (0);
> +	memset(__pdesc, 0, min_t(size_t, _size, TX_DESC_NEXT_DESC_OFFSET))
>
>   struct rx_fwinfo_92c {
>   	u8 gain_trsw[4];
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.h b/drivers/net/wireless/rtlwifi/rtl8192de/trx.h
> index 0dc736c..057a524 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.h
> +++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.h
> @@ -530,12 +530,8 @@
>   	SET_BITS_OFFSET_LE(__pdesc+28, 0, 32, __val)
>
>   #define CLEAR_PCI_TX_DESC_CONTENT(__pdesc, _size)	\
> -do {							\
> -	if (_size>  TX_DESC_NEXT_DESC_OFFSET)		\
> -		memset((void *)__pdesc, 0, TX_DESC_NEXT_DESC_OFFSET);	\
> -	else						\
> -		memset((void *)__pdesc, 0, _size);	\
> -} while (0);
> +	memset((void *)__pdesc, 0,			\
> +	       min_t(size_t, _size, TX_DESC_NEXT_DESC_OFFSET))
>
>   /* For 92D early mode */
>   #define SET_EARLYMODE_PKTNUM(__paddr, __value)		\
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/def.h b/drivers/net/wireless/rtlwifi/rtl8192se/def.h
> index d1b0a1e..20afec6 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192se/def.h
> +++ b/drivers/net/wireless/rtlwifi/rtl8192se/def.h
> @@ -252,12 +252,7 @@
>    * the desc is cleared. */
>   #define	TX_DESC_NEXT_DESC_OFFSET			36
>   #define CLEAR_PCI_TX_DESC_CONTENT(__pdesc, _size)		\
> -do {								\
> -	if (_size>  TX_DESC_NEXT_DESC_OFFSET)			\
> -		memset(__pdesc, 0, TX_DESC_NEXT_DESC_OFFSET);	\
> -	else							\
> -		memset(__pdesc, 0, _size);			\
> -} while (0);
> +	memset(__pdesc, 0, min_t(size_t, _size, TX_DESC_NEXT_DESC_OFFSET))
>
>   /* Rx Desc */
>   #define RX_STATUS_DESC_SIZE				24
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
> index b4afff6..d53f433 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
> +++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
> @@ -345,7 +345,7 @@ enum fw_h2c_cmd {
>   	do {							\
>   		udelay(1000);					\
>   		rtlpriv->rtlhal.fwcmd_iomap&= (~_Bit);		\
> -	} while (0);
> +	} while (0)
>
>   #define FW_CMD_IO_UPDATE(rtlpriv, _val)				\
>   	rtlpriv->rtlhal.fwcmd_iomap = _val;
> @@ -354,13 +354,13 @@ enum fw_h2c_cmd {
>   	do {							\
>   		rtl_write_word(rtlpriv, LBUS_MON_ADDR, (u16)_val);	\
>   		FW_CMD_IO_UPDATE(rtlpriv, _val);		\
> -	} while (0);
> +	} while (0)
>
>   #define FW_CMD_PARA_SET(rtlpriv, _val)				\
>   	do {							\
>   		rtl_write_dword(rtlpriv, LBUS_ADDR_MASK, _val);	\
>   		rtlpriv->rtlhal.fwcmd_ioparam = _val;		\
> -	} while (0);
> +	} while (0)
>
>   #define FW_CMD_IO_QUERY(rtlpriv)				\
>   	(u16)(rtlpriv->rtlhal.fwcmd_iomap)
>
>
>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
