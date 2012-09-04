From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: usbnet: fix softirq storm on suspend
Date: Tue, 04 Sep 2012 10:05:45 +0200
Message-ID: <87r4qiciw6.fsf@nemi.mork.no>
References: <1346660778-24539-1-git-send-email-bjorn@mork.no>
	<CACVXFVNykwxe-PYP_nin32htFmrFL4d=3DEhZMo3UwTEpb81+A@mail.gmail.com>
	<87y5kqcjnp.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87y5kqcjnp.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Tue, 04
	Sep 2012 09:49:14 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> writes:

> And I do believe the code before your change demonstrated that the
> original authors had the same view.  There was an explicit exception =
for
> just this case, and I do assume that was put there for a good
> reason. usbnet_bh() will be called while the device is suspended, and=
 we
> must avoid making it reschedule itself in this case.
>
> Anyway, the ENOLINK test was there.  You removed it with no explanati=
on
> whatsoever. It is *your* call to verify and explain to us why this te=
st
> is unnecessary, not mine.

=46or your convienience, all the reasons why this code ended up like it
was are documented in the netdev patchwork:
http://patchwork.ozlabs.org/patch/59488/

There were different proposed solutions circulating, before the test fo=
r
ENOLINK was chosen.  No-one challenged the fact that some test for a
suspended device was needed here.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
