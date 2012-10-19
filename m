From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 02/14] net: cdc_ncm: use device rx_max value if
 update failed
Date: Fri, 19 Oct 2012 15:53:05 +0200
Message-ID: <CAL_Kpj3tT6qfcD-Tpeqgof-k-PX-EPv_cMFo_NeEdLHfyN8Qfw@mail.gmail.com>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
	<1350592867-25651-3-git-send-email-bjorn@mork.no>
	<3426241.1WN6uXHlgW@linux-lqwf.site>
	<87ehkvv3ej.fsf@nemi.mork.no>
	<CAL_Kpj0j9umyQBFFDVqWqEjH1057EjR0cZRcScdZG30E54=M0w@mail.gmail.com>
	<878vb3ufnx.fsf@nemi.mork.no>
	<871uguvmfy.fsf@nemi.mork.no>
	<CAL_Kpj3QX_bpLh5yX5VXKaqq+TSO9+aVxt+1TrU9e1BamKdFkA@mail.gmail.com>
	<878vb2u03g.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Greg Suarez <gpsuarez2512-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Fangxiaozhi (Franko)" <fangxiaozhi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <878vb2u03g.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2012 at 2:18 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
>
> OK, I may have misunderstood you here.  Quoting the errata text:
>
> <quote>
>   If bit D5 is set in the bmNetworkCapabilities field of function=92s=
 NCM
>   Functional Descriptor, the host may set wLength either to 4 or to
>   8. If wLength is 4, the function shall assume that wNtbInMaxDatagra=
ms
>   is to be set to zero. If wLength is 8, then the function shall use =
the
>   provided value as the limit. The function shall return an error
>   response (a STALL PID) if wLength is set to any other value.
> </quote>
>
> So the 4 byte variant is always supported and we might as well just u=
se
> it unconditionally because we don't set, or need to set, the
> wNtbInMaxDatagrams.
>
> Is that right?  It will simplify the code even more without any loss =
of
> functionality, except for the possibility of failing on some other bu=
ggy
> device not supporting the 4 byte variant...

Agree, since 4-byte version must be supported by all devices,
we can drop 8-byte variant

/alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
