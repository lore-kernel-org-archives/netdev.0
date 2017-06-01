From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] b43legacy: Fix a sleep-in-atomic bug in b43legacy_attr_interfmode_store
Date: Thu, 01 Jun 2017 07:15:51 +0300
Message-ID: <87d1aomjgo.fsf@kamboji.qca.qualcomm.com>
References: <1496226547-5921-1-git-send-email-baijiaju1990@163.com>
        <85905124-7167-aeb0-8aff-4ceec09e9542@lwfinger.net>
        <592F6843.9000204@163.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <592F6843.9000204-9Onoh4P/yGk@public.gmane.org> (Jia-Ju Bai's message of "Thu, 01 Jun
        2017 09:05:07 +0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org> writes:

>> Did you actually observe the attempt to sleep under the spin lock,
>> or did you discover this using some tool? In other words, have
>> either of your patches been tested?
>
> In fact, my reported bugs are found by a static analysis tool written
> by me, and they are checked by my review of the driver code.

It's valuable information to add to the commit log how you found the
bug. If you check other wireless commits you can see comments like
"Found by spatch", "Coverity reported" quite frequently. So I recommend
that you also mention your tool in the commit log, makes understanding
the background of the patch easier.

-- 
Kalle Valo
