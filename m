From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH usb-next 2/2] net: qmi_wwan: add support for ZTE MF820D
Date: Fri, 16 Mar 2012 17:50:05 +0100
Message-ID: <87ty1oebia.fsf@nemi.mork.no>
References: <1331908887-14068-1-git-send-email-bjorn@mork.no>
	<1331908887-14068-3-git-send-email-bjorn@mork.no>
	<20120316151048.GA28696@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120316151048.GA28696-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> (Greg KH's message of "Fri, 16
	Mar 2012 08:10:48 -0700")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> writes:
> On Fri, Mar 16, 2012 at 03:41:27PM +0100, Bj=C3=B8rn Mork wrote:
>> ZTE have yet to discover the magic of USB descriptors.  These
>> devices use ff/ff/ff for class/subclass/protocol regardless of
>> function, except for usb-storage.  Use an interface number
>> whitelist to force the driver to bind only to the QMI/wwan
>> interface.
>>=20
>> Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>> ---
>> Hello Greg and David,
>>=20
>> is it possible to get this into the queue for 3.4 via usb-next as
>> well? It was supposed to be a simple pid/vid addition, but the
>> ZTE descriptor stupidity requires us to match on USB interface
>> numbers.
>
> This requires patch 1/2, right? =20

It doesn't require patch 1/2 of this series, but it does require the
other qmi_wwan patches you've already taken in your tree.

> If so, I'll be glad to take this in my tree if David doesn't mind.

That would be best, yes.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
