From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: usbnet: fix misc bugs
Date: Thu, 3 May 2012 08:34:53 +0800
Message-ID: <CACVXFVPJ71ZqZxTOEYDZ5VaW4C3H2qOmijQHDMi9EZJ-KDVacw@mail.gmail.com>
References: <1335775864-4873-1-git-send-email-tom.leiming@gmail.com>
	<20120502.201444.2074945018843883757.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120502.201444.2074945018843883757.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 3, 2012 at 8:14 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrot=
e:
> From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Mon, 30 Apr 2012 16:51:01 +0800
>
>> These patches fix three bugs in usbnet:
>> =A0 =A0 =A0 usbnet: fix leak of transfer buffer of dev->interrupt
>> =A0 =A0 =A0 usbnet: fix failure handling in usbnet_probe
>> =A0 =A0 =A0 usbnet: fix skb traversing races during unlink(v1)
>
> The third fix looks quite critical, but depends upon an interface
> not present in Linus's tree, nor mine. =A0That doesn't work.
>
> You need to find a way to propagate this fix into Linus's tree
> as well as all -stable trees that need that fix, but without
> this unmet dependency.

OK, usb_block_urb/usb_unlock_urb is not a must to fix the
problem, which is added to speed up the unlink. I will submit
a new version without them.

Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
