From: Michael Kerrisk <mtk.manpages@gmail.com>
Subject: Re: [PATCH 2/2] man - IP_NODEFRAG option for IPv4 socket
Date: Sat, 26 Jun 2010 15:01:03 +0200
Message-ID: <AANLkTim4N5rc8Sn_uo5bXsb9vjvKd3GTQD3p-1uApbB8@mail.gmail.com>
References: <1276600052-16499-1-git-send-email-jolsa@redhat.com>
	<1276600052-16499-3-git-send-email-jolsa@redhat.com>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, jengelh@medozas.de, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-man@vger.kernel.org
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276600052-16499-3-git-send-email-jolsa@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

Thanks for this patch. See below.

On Tue, Jun 15, 2010 at 1:07 PM, Jiri Olsa <jolsa@redhat.com> wrote:
> hi,
>
> this patch adds description for IP_NODEFRAG option for IPv4 socket.
>
> wbr,
> jirka
>
>
> Signed-off-by: Jiri Olsa <jolsa@redhat.com>
> ---
> =A0man7/ip.7 | =A0 =A06 ++++++
> =A01 files changed, 6 insertions(+), 0 deletions(-)
>
> diff --git a/man7/ip.7 b/man7/ip.7
> index 34f7e80..12c0d5b 100644
> --- a/man7/ip.7
> +++ b/man7/ip.7
> @@ -705,6 +705,12 @@ socket option (see
> =A0.BR IP_TTL " (since Linux 1.0)"
> =A0Set or retrieve the current time-to-live field that is used in eve=
ry packet
> =A0sent from this socket.
> +.TP
> +.BR IP_NODEFRAG " (since Linux 2.6)"

here, we'd write the exact version in which the flag is added. It
looks like that might be 2.36, right?

Otherwise, this patch looks fine.

Cheers,

Michael



> +If enabled, the reassembly of outgoing packets is disabled in the ne=
tfilter layer.
> +Only valid for
> +.B SOCK_RAW
> +sockets.
> =A0.\" FIXME Document IP_XFRM_POLICY
> =A0.\" Since Linux 2.5.48
> =A0.\" Needs CAP_NET_ADMIN
> --
> To unsubscribe from this list: send the line "unsubscribe linux-man" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface" http://blog.man7.org/
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
