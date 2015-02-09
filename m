From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2015-02-07
Date: Mon, 09 Feb 2015 14:49:42 -0600
Message-ID: <54D91D66.2060108@lwfinger.net>
References: <87a90qosos.fsf@kamboji.qca.qualcomm.com> <20150209.121342.1535841700027616341.davem@davemloft.net> <20150209203741.GG3566@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150209203741.GG3566-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/09/2015 02:37 PM, John W. Linville wrote:
> On Mon, Feb 09, 2015 at 12:13:42PM -0800, David Miller wrote:
>> From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>> Date: Sat, 07 Feb 2015 13:40:51 +0200
>>
>>> There's a small conflict in drivers/net/wireless/rtlwifi/pci.c, the=
 fix
>>> is to leave the two labels like this:
>>>
>>> 			schedule_work(&rtlpriv->works.lps_change_work);
>>> 		}
>>> end:
>>> 		skb =3D new_skb;
>>> no_new:
>>> 		if (rtlpriv->use_new_trx_flow) {
>>>
>>>
>>
>> That can't be the correct resolution:
>>
>> drivers/net/wireless/rtlwifi/pci.c: In function =E2=80=98_rtl_pci_rx=
_interrupt=E2=80=99:
>> drivers/net/wireless/rtlwifi/pci.c:934:1: warning: label =E2=80=98en=
d=E2=80=99 defined but not used [-Wunused-label]
>>
>> So I've removed that label in the merge commit.
>
> FWIW, that's the way I have it in wireless-testing as well..

I must have missed the pull request. Removal of the label "end" is corr=
ect.

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
