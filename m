From: Michael Kerrisk <mtk.manpages@gmail.com>
Subject: Re: Documentation for IP_TRANSPARENT?
Date: Wed, 13 Oct 2010 07:16:42 +0200
Message-ID: <AANLkTika83PJ_KkmE+3Rhi4JgTjEZHTDzV-hcyz_UCWB@mail.gmail.com>
References: <cfd18e0f0811240806w541c85e9gafbcc80e8101f2b2@mail.gmail.com> <1228828648.7631.75.camel@bzorp.balabit>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <1228828648.7631.75.camel@bzorp.balabit>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Bazsi

A long time after your mail, I've now added the text you supplied
below. The changes are now available via git, and will be in
man-pages-3.29. However, I have a few small questions that you can
maybe clarify. See below.

On Tue, Dec 9, 2008 at 2:17 PM, Balazs Scheidler <bazsi@balabit.hu> wro=
te:
> Hi,
>
> On Mon, 2008-11-24 at 11:06 -0500, Michael Kerrisk wrote:
>> Hello Krisztian,
>>
>> Your 2.6.27 patch adds =A0the IP_TRANSPARENT socket option. =A0Could=
 you
>> please supply some documentation (plain text is fine) suitable for
>> inclusion in the ip(7) man page.
>
> Although it was Krisztian who originally submitted the patches, but I
> also did some things about them, so here I gave the documentation par=
t a
> spin.
>
> There are some other related options, that are undocumented right now=
,
> so I tried to give documentation on those as well.
>
> IP_FREEBIND
> =A0 =A0 =A0 =A0Enable binding to IP addresses that do not currently e=
xist. When
> =A0 =A0 =A0 =A0enabled on a TCP or UDP socket, the bind(2) call refer=
encing a
> =A0 =A0 =A0 =A0non-existing IP address will succeed. This functionali=
ty is useful
> =A0 =A0 =A0 =A0if the specified IP address is dynamic (e.g. assigned =
to a PPP device)
> =A0 =A0 =A0 =A0and is down at the time when the application is trying=
 to bind to it.
> =A0 =A0 =A0 =A0This setsockopt is the per-socket equivalent to ip_non=
local_bind sysctl.
>
> IP_TRANSPARENT
> =A0 =A0 =A0 =A0Enable transparent proxying on this socket. This socke=
t option allows
> =A0 =A0 =A0 =A0the calling application to bind to a non-local IP addr=
ess and operate
> =A0 =A0 =A0 =A0both as a client and a server with the foreign address=
 as the local
> =A0 =A0 =A0 =A0endpoint. NOTE: this requires that routing be set up i=
n a way that
> =A0 =A0 =A0 =A0packets going to the foreign address are routed throug=
h the tproxy box.

Can you say a few words explaining what is meant by "tproxy box".

Also, should one write "TProxy" here, analogous with "TProxy" below?

> =A0 =A0 =A0 =A0Enabling this socket option requires superuser privile=
ges
> =A0 =A0 =A0 =A0(more specifically the CAP_NET_ADMIN capability).
>
> =A0 =A0 =A0 =A0TProxy redirection with the iptables TPROXY target als=
o requires that
> =A0 =A0 =A0 =A0this option be set on the redirected socket.

In iptables(8), I find no mention of TPROXY. Is it just that the
iptables(8) man page is not up to date?

> IP_RECVORIGDSTADDR
> =A0 =A0 =A0 =A0Enables the IP_ORIGDSTADDR ancillary message in recvms=
g(2) in which
> =A0 =A0 =A0 =A0the kernel returns the original destination address of=
 a datagram. The
> =A0 =A0 =A0 =A0ancillary message contains a "struct sockaddr_in" inst=
ance.

Do you happen to know of any userspace test code that demonstrates the
use of IP_RECVORIGDSTADDR?

Thanks for this documentation, and sorry it took so long to make its
way into man-pages.

Cheers,

Michael

--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
