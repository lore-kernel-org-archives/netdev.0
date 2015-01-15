From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH for 3.19 2/3] rtlwifi: Fix handling of new style descriptors
Date: Thu, 15 Jan 2015 14:00:52 +0200
Message-ID: <87y4p4w8wb.fsf@kamboji.qca.qualcomm.com>
References: <1421257036-5382-1-git-send-email-Larry.Finger@lwfinger.net>
	<1421257036-5382-3-git-send-email-Larry.Finger@lwfinger.net>
	<877fwoxo7g.fsf@kamboji.qca.qualcomm.com>
	<C11178B3EB8EC446A461ADCC3E27182146C9A9F8@rsex2.realsil.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "larry.finger" <Larry.Finger@lwfinger.net>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: =?utf-8?B?6LCt5p2t5rOi?= <troy_tan@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:55091 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbbAOMA7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 07:00:59 -0500
In-Reply-To: <C11178B3EB8EC446A461ADCC3E27182146C9A9F8@rsex2.realsil.com.cn>
	(=?utf-8?B?IuiwreadreazoiIncw==?= message of "Thu, 15 Jan 2015 11:46:55
 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Troy,

please avoid top-posting.

=E8=B0=AD=E6=9D=AD=E6=B3=A2 <troy_tan@realsil.com.cn> writes:

> You can find get_available_desc here:
>
> diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireles=
s/rtlwifi/
> pci.c
> index e25faac..a62170e 100644
> --- a/drivers/net/wireless/rtlwifi/pci.c
> +++ b/drivers/net/wireless/rtlwifi/pci.c
> @@ -578,6 +578,13 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw =
*hw, int
> prio)
>                 else
>                         entry =3D (u8 *)(&ring->desc[ring->idx]);
>
> +               if (rtlpriv->cfg->ops->get_available_desc &&
> +                   rtlpriv->cfg->ops->get_available_desc(hw, prio) <=
=3D 1) {
> +                       RT_TRACE(rtlpriv, (COMP_INTR | COMP_SEND), DB=
G_DMESG,
> +                                "no available desc!\n");
> +                       return;
> +               }

I don't see rtlpriv->cfg->ops->get_available_desc set here, only being
called?

--=20
Kalle Valo
