From: Boian Bonev <boian@bonev.com>
Subject: Re: dst cache overflow messages
Date: Mon, 21 Mar 2005 04:05:26 +0200
Message-ID: <20050321020526.20420.qmail@orange.bonev.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_1_1111370726_20417"
Content-Transfer-Encoding: 8bit
Cc: buakaw@buakaw.homelinux.net
To: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_1_1111370726_20417
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: quoted-printable

hi,

this happens very rare. it is mostly seen on systems with full bgp table =
combined with a massive scan on diverse networks caused by worms/troyans/=
etc.

you can tuneup your systems' max route cache size by
echo sane-big-value > /proc/sys/net/ipv4/route/max_size

if you happen to get a permanent attack, you may also need to twiddle wit=
h garbage collection values in /proc/sys/net/ipv4/route/gc_* to ensure th=
at the route cache will not grow more than the max value for the period o=
f gc.

b.



> ----- Original Message ----
> From: Andrew Morton <akpm@osdl.org>
> To: netdev@oss.sgi.com
> Sent: Sun, 20 Mar 2005 16:37:25 -0800
> Subject: Fw: dst cache overflow messages
>
> 
> 
> Begin forwarded message:
> 
> Date: Sun, 20 Mar 2005 22:51:08 +0200 (EET)
> From: buakaw@buakaw.homelinux.net
> To: linux-kernel@vger.kernel.org
> Subject: 
> 
> 
> the system become very laggy.
> i use kernel 2.6.10/2.6.11.3 on p4 2.8, msi915p, 3 x 3com905 boomerang.=

> and the cpu usage normally be about 12% and after something happens it
> boost to 100% and it is used mostly by ksoftirqd/0, and a little bit by=
 
> migration/0 and event/0. and in syslog i found thies lines
> 
> Mar 20 22:21:09 buakaw kernel: printk: 5543 messages suppressed.
> Mar 20 22:21:09 buakaw kernel: dst cache overflow
> 
> what can cause this?

--=_1_1111370726_20417--
