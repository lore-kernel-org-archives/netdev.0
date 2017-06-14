From: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: Re: [PATCH] mwifiex: fixes the trivial print
Date: Wed, 14 Jun 2017 19:11:16 +0800
Message-ID: <107d0efe-b056-96d1-e129-31f4ddfd23c9@rock-chips.com>
References: <1497008411-15223-1-git-send-email-wxt@rock-chips.com>
 <87poe8pfjs.fsf@purkki.adurom.net>
 <b5621250-c9c8-b413-0dae-88b326c729bf@rock-chips.com>
 <87mv9c74hn.fsf@kamboji.qca.qualcomm.com>
 <2eb9e680-64bc-a74d-f224-b6e13dd3b45b@rock-chips.com>
 <87ink0728l.fsf@kamboji.qca.qualcomm.com>
 <9e123f64d71c466b8a6dc908a51eeb71@SC-EXCH02.marvell.com>
 <cf947dd3-e3a9-e940-fa15-393c9d952f32@rock-chips.com>
 <9f6c89acb50b4be3b8bde3291eac891b@SC-EXCH02.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Zhiyuan Yang <yangzy-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Cathy Luo <cluo-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        "amitkarwar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <amitkarwar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Ganapathi Bhat <gbhat-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org" <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "jeffy.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org" <jeffy.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Xinming Hu <huxm-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9f6c89acb50b4be3b8bde3291eac891b-uAViF8V/CPNq65YQV0AP9hL4W9x8LtSr@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


在 2017年06月14日 18:23, Xinming Hu 写道:
> Hi Caesar,
> 
> It proved to be a feature to get better scan result from overlapping channel, introduced in
> 
> commit 1b499cb72f26bbf44f2fa158c2d1487730aae96a
> Author: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
> Date:   Sun Apr 24 23:49:51 2016 -0700
> 
>      mwifiex: disable channel filtering feature in firmware
>      
>      As 2.4Ghz channels are overlapping, sometimes AP responds to
>      probe request even if it's operating on neighbouring channel.
>      Currently firmware drops those scan entries, as current channel
>      doesn't match with APs channel.
>      
>      This patch enables MWIFIEX_DISABLE_CHAN_FILT flag in scan
>      command to disable the feature so that better scan results
>      will be received in 2.4Ghz band.
> 
> As I can see, even there could be AP from overlapping channel (might be 12/13/14 in this case),  it will be filtered depend on reg domain rules
>   
>         if (ch->flags & IEEE80211_CHAN_DISABLED)
>              continue;
> 
> so it should not been an ERROR. WARN looks fine to me.
> you can add me acked-by in v2.


Okay, thanks for explanation and having a look at it.


-Caesar

> 
> 
> Regards,
> Simon
> From: Caesar Wang [mailto:wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org]
> Sent: 2017年6月13日 18:52
> To: Xinming Hu; Kalle Valo; Zhiyuan Yang; Cathy Luo
> Cc: amitkarwar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; Nishant Sarmukadam; Ganapathi Bhat; linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org; jeffy.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org; Ganapathi Bhat
> Subject: [EXT] Re: [PATCH] mwifiex: fixes the trivial print
> 
> External Email
> ________________________________________
> Hi Xinming,
> As issue tracked on https://partnerissuetracker.corp.google.com/u/2/issues/62122843
> 
> 
> 在 2017年06月13日 17:51, Xinming Hu 写道:
> Hi Caesar,
> 
> The original log in google issue tracker show there exist AP in channel 13 after periodically scan.
> Per my understand, if reg domain is set to US,  channel 12/13/14 will not get chance to scan. (test using iw/wpa_supplicant).
> I am curious about whether there are any diff from upper layer.
> 
> As a test, you can print the scan channel list, as below:
> 
> diff --git a/drivers/net/wireless/marvell/mwifiex/cfg80211.c b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
> index a7593aa..a289818 100644
> --- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
> +++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
> @@ -2572,6 +2572,7 @@ static int mwifiex_set_ibss_params(struct mwifiex_private *priv,
>                                MWIFIEX_USER_SCAN_CHAN_MAX); i++) {
>                  chan = request->channels[i];
>                  user_scan_cfg->chan_list[i].chan_number = chan->hw_value;
> +               pr_err("chan->hw_value = %d", chan->hw_value);
>                  user_scan_cfg->chan_list[i].radio_type = chan->band;
>   
>                  if ((chan->flags & IEEE80211_CHAN_NO_IR) || !request->n_ssids)
> 
> The below as the required log:
> localhost / # [   46.760997] mwifiex: chan->hw_value = 1
> [   46.764878] mwifiex: chan->hw_value = 2
> [   46.768765] mwifiex: chan->hw_value = 3
> [   46.772625] mwifiex: chan->hw_value = 4
> [   46.776608] mwifiex: chan->hw_value = 5
> [   46.780485] mwifiex: chan->hw_value = 6
> [   46.784384] mwifiex: chan->hw_value = 7
> [   46.788252] mwifiex: chan->hw_value = 8
> [   46.792185] mwifiex: chan->hw_value = 9
> [   46.796036] mwifiex: chan->hw_value = 10
> [   46.799978] mwifiex: chan->hw_value = 11
> [   46.803908] mwifiex: chan->hw_value = 38
> [   46.807847] mwifiex: chan->hw_value = 42
> [   46.811786] mwifiex: chan->hw_value = 46
> [   46.815722] mwifiex: chan->hw_value = 36
> [   46.819646] mwifiex: chan->hw_value = 40
> [   46.823577] mwifiex: chan->hw_value = 44
> [   46.827503] mwifiex: chan->hw_value = 48
> [   46.831440] mwifiex: chan->hw_value = 52
> [   46.835363] mwifiex: chan->hw_value = 56
> [   46.839287] mwifiex: chan->hw_value = 60
> [   46.843205] mwifiex: chan->hw_value = 64
> [   46.847129] mwifiex: chan->hw_value = 100
> [   46.851134] mwifiex: chan->hw_value = 104
> [   46.855150] mwifiex: chan->hw_value = 108
> [   46.859155] mwifiex: chan->hw_value = 112
> [   46.863168] mwifiex: chan->hw_value = 116
> [   46.867175] mwifiex: chan->hw_value = 120
> [   46.871186] mwifiex: chan->hw_value = 124
> [   46.875196] mwifiex: chan->hw_value = 128
> [   46.879208] mwifiex: chan->hw_value = 132
> [   46.883214] mwifiex: chan->hw_value = 136
> [   46.887224] mwifiex: chan->hw_value = 140
> [   46.891230] mwifiex: chan->hw_value = 149
> [   46.895241] mwifiex: chan->hw_value = 153
> [   46.899246] mwifiex: chan->hw_value = 157
> [   46.903256] mwifiex: chan->hw_value = 161
> [   46.907262] mwifiex: chan->hw_value = 165
> [   47.394176] mwifiex_pcie 0000:01:00.0: mwifiex_get_cfp: cannot find cfp by band 2    & channel=12 freq=0
> 
> -Caesar
> 
> 
> Regards,
> Simon
> 
> -----Original Message-----
> From: Kalle Valo [mailto:kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org]
> Sent: 2017年6月13日 15:53
> To: Caesar Wang
> Cc: amitkarwar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; Xinming Hu; Nishant Sarmukadam; Ganapathi
> Bhat; linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org;
> jeffy.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org
> Subject: [EXT] Re: [PATCH] mwifiex: fixes the trivial print
> 
> External Email
> 
> ----------------------------------------------------------------------
> Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org> writes:
> 
> 在 2017年06月13日 15:04, Kalle Valo 写道:
> Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org> writes:
> 
> Kalle,
> 
> 在 2017年06月13日 14:28, Kalle Valo 写道:
> Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org> writes:
> 
> We have always met the unused log be printed as following.
> 
> ...
> [23193.523182] mwifiex_pcie 0000:01:00.0: mwifiex_get_cfp:
> cannot find cfp by band 2    & channel=13 freq=0
> [23378.633684] mwifiex_pcie 0000:01:00.0: mwifiex_get_cfp:
> cannot find cfp by band 2    & channel=13 freq=0
> 
> Maybe that's related to wifi regdom, since wifi default area was
> US and didn't support 12~14 channels.
> 
> As Frequencies:
> * 2412 MHz [1] (30.0 dBm)
> * 2417 MHz [2] (30.0 dBm)
> * 2422 MHz [3] (30.0 dBm)
> * 2427 MHz [4] (30.0 dBm)
> * 2432 MHz [5] (30.0 dBm)
> * 2437 MHz [6] (30.0 dBm)
> * 2442 MHz [7] (30.0 dBm)
> * 2447 MHz [8] (30.0 dBm)
> * 2452 MHz [9] (30.0 dBm)
> * 2457 MHz [10] (30.0 dBm)
> * 2462 MHz [11] (30.0 dBm)
> * 2467 MHz [12] (disabled)
> * 2472 MHz [13] (disabled)
> * 2484 MHz [14] (disabled)
> 
> Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> ---
> 
>     drivers/net/wireless/marvell/mwifiex/cfp.c | 2 +-
>     1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/marvell/mwifiex/cfp.c
> b/drivers/net/wireless/marvell/mwifiex/cfp.c
> index 1ff2205..6e29943 100644
> --- a/drivers/net/wireless/marvell/mwifiex/cfp.c
> +++ b/drivers/net/wireless/marvell/mwifiex/cfp.c
> @@ -350,7 +350,7 @@ mwifiex_get_cfp(struct mwifiex_private *priv, u8
> band, u16 channel, u32 freq)
>     		}
>     	}
>     	if (i == sband->n_channels) {
> -		mwifiex_dbg(priv->adapter, ERROR,
> +		mwifiex_dbg(priv->adapter, WARN,
>     			    "%s: cannot find cfp by band %d\t"
>     			    "& channel=%d freq=%d\n",
>     			    __func__, band, channel, freq);
> I don't see how this fixes anything, care to explain? And the title
> is quite vague.
> Sorry for the description maybe unclear.
> I'm assuming the print log is expected for marvel wifi driver. Do we
> should use 'WARN' to instead of the 'ERROR' here.
> But does that make any functional difference, isn't the warning still
> printed?
> 
> 
> At least, that shouldn't be printed log by default.  :)
> 
> if I read the code is correct. That only the MSG/FATAL/ERROR will
> output by default.
> 
> /**
>   *enum mwifiex_debug_level  -  marvell wifi debug level  */ enum
> MWIFIEX_DEBUG_LEVEL {
>      MWIFIEX_DBG_MSG        = 0x00000001,
>      MWIFIEX_DBG_FATAL    = 0x00000002,
>      MWIFIEX_DBG_ERROR    = 0x00000004,
>      MWIFIEX_DBG_DATA    = 0x00000008,
>      MWIFIEX_DBG_CMD        = 0x00000010,
>      MWIFIEX_DBG_EVENT    = 0x00000020,
>      MWIFIEX_DBG_INTR    = 0x00000040,
>      MWIFIEX_DBG_IOCTL    = 0x00000080,
> 
>      MWIFIEX_DBG_MPA_D    = 0x00008000,
>      MWIFIEX_DBG_DAT_D    = 0x00010000,
>      MWIFIEX_DBG_CMD_D    = 0x00020000,
>      MWIFIEX_DBG_EVT_D    = 0x00040000,
>      MWIFIEX_DBG_FW_D    = 0x00080000,
>      MWIFIEX_DBG_IF_D    = 0x00100000,
> 
>      MWIFIEX_DBG_ENTRY    = 0x10000000,
>      MWIFIEX_DBG_WARN    = 0x20000000,
>      MWIFIEX_DBG_INFO    = 0x40000000,
>      MWIFIEX_DBG_DUMP    = 0x80000000,
> 
>      MWIFIEX_DBG_ANY        = 0xffffffff
> };
> 
> #define MWIFIEX_DEFAULT_DEBUG_MASK    (MWIFIEX_DBG_MSG | \
>                      MWIFIEX_DBG_FATAL | \
>                      MWIFIEX_DBG_ERROR)
> 
> Heh, makes more sense now :) But you still should improve the title and
> explain in the commit log that WARN level is not printed by default.
> 
> But before you submit v2 let's wait what Marvell says about this.
> 
> --
> Kalle Valo
> 
