From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [RFC] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 11:52:22 +0100
Message-ID: <87bocehmzd.fsf@nemi.mork.no>
References: <1359023152-32576-1-git-send-email-bjorn@mork.no>
	<6505263.QGCG9bfoCC@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6505263.QGCG9bfoCC-7ztolUikljGernLeA6q8OA@public.gmane.org> (Oliver Neukum's message of
	"Thu, 24 Jan 2013 11:46:52 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> writes:

> On Thursday 24 January 2013 11:25:52 Bj=C3=B8rn Mork wrote:
>> The MBIM firmware for the Sierra Wireless MC7710 is a nice source
>> of "interesting" device issues.  One of the uglier ones is that
>> it under certain conditions will start flooding us with frames
>> having length 0 as fast as it can.  And that is pretty fast...
>
> If you can tell that those frames are bogus, why not count them
> as opposed to generic qlen? Say, if you see 20 among the last 30
> are of this type, throttle.

Sounds like a good idea, but where do I add/get that statistics?


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
