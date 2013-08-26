From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP exception table
Date: Mon, 26 Aug 2013 03:10:38 +0200
Message-ID: <87zjs5s1dd.fsf@nemi.mork.no>
References: <20130825182913.2865aa1a8cefe329ab9c7a85@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: Rob Gardner <robmatic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130825182913.2865aa1a8cefe329ab9c7a85-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Rob
	Gardner's message of "Sun, 25 Aug 2013 18:29:13 -0600")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rob Gardner <robmatic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> From 018343ce2e679d97283fb51da25c43aa876d087a Mon Sep 17 00:00:00 200=
1
> From: Rob Gardner <robmatic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sun, 25 Aug 2013 16:02:23 -0600
> Subject: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP exc=
eption table
>
> This patch adds another entry (HP hs2434 Mobile Broadband) to the lis=
t
> of exceptional devices that require a zero length packet in order to
> function properly. This list was added in commit 844e88f0. The hs2434
> is manufactured by Sierra Wireless, who also produces the MC7710,
> which the ZLP exception list was created for in the first place. So
> hopefully it is just this one producer's devices that will need this
> workaround.
>
> Tested on a DM1-4310NR HP notebook, which does not function without t=
his
> change.
>
> Signed-off-by: Rob Gardner <robmatic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Acked-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Thanks a lot for doing this!


As I warned about in http://www.spinics.net/lists/netdev/msg223742.html
I am now going to reconsider what do do about this issue. There are onl=
y
two devices in the exception list so far, but I would like to note that
this represents 100% of the Sierra Wireless MBIM devices we *know* are
tested with this driver.

Testing for this firmware bug and verifying the workaround on a new
device is currently hard, requiring more skills than most end users can
be expected to have. I therefore find it very likely that we will miss
(or quite possible have missed already) a number of devices which shoul=
d
have been in this exception list. I believe we have to do something
about this.

Ideas are welcome.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
