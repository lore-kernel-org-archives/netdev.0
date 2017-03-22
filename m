From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [2/2] zd1211rw: fix NULL-deref at probe
Date: Wed, 22 Mar 2017 15:02:12 +0200
Message-ID: <87r31p31nv.fsf@kamboji.qca.qualcomm.com>
References: <20170313124421.28587-2-johan@kernel.org>
        <20170322090415.BE414609FF@smtp.codeaurora.org>
        <20170322124548.GC10130@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
        Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170322124548.GC10130@localhost> (Johan Hovold's message of
        "Wed, 22 Mar 2017 13:45:48 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:

> On Wed, Mar 22, 2017 at 09:04:15AM +0000, Kalle Valo wrote:
>> Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>> > Make sure to check the number of endpoints to avoid dereferencing a
>> > NULL-pointer or accessing memory beyond the endpoint array should a
>> > malicious device lack the expected endpoints.
>> > 
>> > Fixes: a1030e92c150 ("[PATCH] zd1211rw: Convert installer CDROM
>> > device into WLAN device")
>> > Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
>> > Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> 
>> Patch applied to wireless-drivers-next.git, thanks.
>> 
>> ca260ece6a57 zd1211rw: fix NULL-deref at probe
>
> What about patch 1/2 which fixes the same bug (literally copied from the
> zd1211rw driver)?

I will apply that to my separate ath.git tree, just didn't get to your
patch yet.

> And as these fixes should be backported to stable (I left out the tag
> for networking drivers)

Actually for wireless drivers you should add the stable tag.

> why only apply to -next?

I didn't see that the fix was important enough for 4.11.

-- 
Kalle Valo
