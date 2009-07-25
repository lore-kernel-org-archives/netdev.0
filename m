From: Michael Kerrisk <mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH] man page update (ip.7) to reflect new socket option in
	2.6.31
Date: Sat, 25 Jul 2009 06:43:42 +0200
Message-ID: <cfd18e0f0907242143i3de2ff52ke2d18e7dc03032e5@mail.gmail.com>
References: <4A3B37FD.4040801@us.ibm.com> <4A3B3C92.9050003@us.ibm.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Nivedita Singhvi <niv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4A3B3C92.9050003-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Nivedita

On Fri, Jun 19, 2009 at 9:21 AM, Nivedita Singhvi<niv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote=
:
> Nivedita Singhvi wrote:
>>
>> This patch adds the IP_MULTICAST_ALL option to
>> the ip.7 man page, to bring it up to date with
>> 2.6.31 development.
>
> Ah, the "since" is intended to be inclusive.

Yep ;-).

> The
> 2.6.30 needs to be 2.6.31. Correct version below.
> Apologies!

No worries. Glad you caught it. Some belated comments below.

> Signed-off-by: Nivedita Singhvi <niv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>
> ---
> =A0man7/ip.7 | =A0 10 +++++++++-
> =A01 files changed, 9 insertions(+), 1 deletions(-)
>
> diff --git a/man7/ip.7 b/man7/ip.7
> index ab866a1..6932ba2 100644
> --- a/man7/ip.7
> +++ b/man7/ip.7
> @@ -357,7 +357,6 @@ and retrieve the MTU by calling
> =A0with the
> =A0.B IP_MTU
> =A0option.
> -
> =A0It is possible to implement RFC 4821 MTU probing with
> =A0.B SOCK_DGRAM
> =A0or
> @@ -383,6 +382,15 @@ When an invalid socket option is passed,
> =A0.B ENOPROTOOPT
> =A0is returned.
> =A0.TP
> +.BR IP_MULTICAST_ALL " (since Linux 2.6.31)"
> +Sets the multicast delivery policy to the socket. =A0Argument is a b=
oolean

Is the following better here:
Sets the policy for multicast delivery to the socket
?

> +integer that enables or disables multicast delivery from all groups.
> +If not set, delivery to the socket is restricted to data from those
> multicast
> +groups that have been explicitly subscribed to via a multicast join
> operation
> +for this socket. The default is 1 which means that a socket which is=
 bound
> +to the wildcard address (INADDR_ANY) will receive multicast packets =
from
> all
> +groups that have been subscribed to on this system.
> +.TP
> =A0.BR IP_MULTICAST_LOOP " (since Linux 1.2)"

Cheers,

Michael

--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Watch my Linux system programming book progress to publication!
http://blog.man7.org/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
