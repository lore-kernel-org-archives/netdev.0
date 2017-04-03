From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 1/2] wireless: ath9k_htc: fix NULL-deref at probe
Date: Mon, 03 Apr 2017 12:34:26 +0300
Message-ID: <87shlpomvx.fsf@kamboji.qca.qualcomm.com>
References: <20170313124421.28587-1-johan@kernel.org>
        <20170403084213.GE25742@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
        Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Sujith Manoharan <Sujith.Manoharan-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
To: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170403084213.GE25742@localhost> (Johan Hovold's message of
        "Mon, 3 Apr 2017 10:42:13 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:

> On Mon, Mar 13, 2017 at 01:44:20PM +0100, Johan Hovold wrote:
>> Make sure to check the number of endpoints to avoid dereferencing a
>> NULL-pointer or accessing memory beyond the endpoint array should a
>> malicious device lack the expected endpoints.
>> 
>> Fixes: 36bcce430657 ("ath9k_htc: Handle storage devices")
>> Cc: Sujith Manoharan <Sujith.Manoharan-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
>> Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>
> Is this one still in your queue, Kalle?

Yes, I'm just lacking behing:

https://patchwork.kernel.org/patch/9620723/

> As I mentioned earlier, I should have added a
>
> Cc: stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>     # 2.6.39
>
> but left it out as I mistakingly thought the net recommendations to do
> so applied also to wireless.

Ok, I'll add that.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
