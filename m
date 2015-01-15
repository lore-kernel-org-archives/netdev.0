From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH for 3.19 2/3] rtlwifi: Fix handling of new style descriptors
Date: Thu, 15 Jan 2015 14:10:18 -0600
Message-ID: <54B81EAA.9040706@lwfinger.net>
References: <1421257036-5382-1-git-send-email-Larry.Finger@lwfinger.net>	<1421257036-5382-3-git-send-email-Larry.Finger@lwfinger.net>	<877fwoxo7g.fsf@kamboji.qca.qualcomm.com>	<C11178B3EB8EC446A461ADCC3E27182146C9A9F8@rsex2.realsil.com.cn> <87y4p4w8wb.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	=?UTF-8?B?6LCt5p2t5rOi?= <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87y4p4w8wb.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/15/2015 06:00 AM, Kalle Valo wrote:
> Hi Troy,
>
> please avoid top-posting.
>
> =E8=B0=AD=E6=9D=AD=E6=B3=A2 <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org> writes:
>
>> You can find get_available_desc here:
>>
>> diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wirele=
ss/rtlwifi/
>> pci.c
>> index e25faac..a62170e 100644
>> --- a/drivers/net/wireless/rtlwifi/pci.c
>> +++ b/drivers/net/wireless/rtlwifi/pci.c
>> @@ -578,6 +578,13 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw=
 *hw, int
>> prio)
>>                  else
>>                          entry =3D (u8 *)(&ring->desc[ring->idx]);
>>
>> +               if (rtlpriv->cfg->ops->get_available_desc &&
>> +                   rtlpriv->cfg->ops->get_available_desc(hw, prio) =
<=3D 1) {
>> +                       RT_TRACE(rtlpriv, (COMP_INTR | COMP_SEND), D=
BG_DMESG,
>> +                                "no available desc!\n");
>> +                       return;
>> +               }
>
> I don't see rtlpriv->cfg->ops->get_available_desc set here, only bein=
g
> called?

Kalle,

Troy and I will try to prepare a patch that only fixes the bugs, and we=
 will=20
submit the cleanup for -next.

Sorry for the noise,

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
