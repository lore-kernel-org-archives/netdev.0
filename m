From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net 0/3] qmi_wwan: simplify device matching and add a few new devices
Date: Mon, 13 Aug 2012 12:39:09 +0200
Message-ID: <87mx1zjctu.fsf@nemi.mork.no>
References: <1344798992-10176-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1344798992-10176-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
 (=?utf-8?Q?=22Bj=C3=B8rn?= Mork"'s
	message of "Sun, 12 Aug 2012 21:16:29 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> writes:

> The home cooked whitelisting code can be removed now that=20
> the USB core supports interface number matching.
>
> The second patch adds a few new devices.
>
> The third patch improves device list readability by using
> existing macros where possible.
>
> I hope this can go in 3.6-rc2/3. The series is based on
> the current net/master (commit 2359a476)

Just an additional afterthought: Please do not apply this as it is to
"net-next" if you decide it is inappropriate for "net".

New devices will be added to the driver during the 3.6 cycle whether or
not the probing changes are accepted.  This will result in unnecessary
merge conflicts. I'll submit a new version of the patch set for
"net-next" when we have a better idea of what the device list looks lik=
e
at the beginning of the 3.7 cycle.

But I am still hoping this is accepted for "net", although I obviously
screwed up choosing strategy to avoid net/usb merge conflicts.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
