From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Thu, 28 Jun 2012 16:54:14 -0700 (PDT)
Message-ID: <20120628.165414.1206750826483224087.davem@davemloft.net>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<87lij7de8u.fsf@nemi.mork.no>
	<201206281040.55402.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn-yOkvZcmFvRU@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201206281040.55402.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date: Thu, 28 Jun 2012 10:40:55 +0200

> Am Donnerstag, 28. Juni 2012, 10:36:49 schrieb Bj=F8rn Mork:
>> I'd like this patch applied to qmi_wwan regardless of the outcome of=
 the
>> (now stalled?) generic usbnet_disconnect discussion.
>>=20
>> The patch fixes a real Oops in 3.4 and 3.5, and I believe it should =
be
>> left in qmi_wwan even if the usbnet code is fixed to avoid this spec=
ific
>> bug.  The additional NULL test won't harm, and it makes the code mor=
e
>> robust should someone decide to rearrange usbnet_disconnect again at
>> some later point in time.
>>=20
>> I really want this fixed in the next 3.4 stable release, if possible=
=2E
>> Should I resubmit the patch, or will you pick it up from
>> http://patchwork.ozlabs.org/patch/166542/ ?
>=20
> Yes.
>=20
> David, can you please apply this? It needs to also go into stable.
> We might remove this in later releases, but for now it is needed.

Done.  I left the stable CC: in there so Greg will pick this up
automatically once it hits Linus's tree.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
