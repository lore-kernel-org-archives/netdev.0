From: Andrew Morton <akpm@osdl.org>
Subject: Fw: ppp0 out of control
Date: Mon, 24 Jan 2005 15:59:12 -0800
Message-ID: <20050124155912.53e90409.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Mon__24_Jan_2005_15_59_12_-0800_KNED1cU+/MA4IIE+"
Cc: =?ISO-8859-1?Q?Aur=E9lien_G=C9R=D4ME?= <ag@roxor.be>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Mon__24_Jan_2005_15_59_12_-0800_KNED1cU+/MA4IIE+
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable



Begin forwarded message:

Date: Fri, 21 Jan 2005 15:44:44 +0100
From: Aur=E9lien G=C9R=D4ME <ag@roxor.be>
To: linux-kernel@vger.kernel.org
Subject: ppp0 out of control


Hi there,

I am running 2.6.10 from kernel.org on Debian Sid ppc/x86, the same
issue occurs with 2.6.9. Though, 2.6.8.1 and previous are fine.

When my ISP connection via PPPoE (kernel side) goes down, reconnection
does not occur, and the kernel displays continuous:

kernel: unregister_netdevice: waiting for ppp0 to become free. Usage count =
=3D 1

This is that on both machine: x86 and ppc.

The only solution is a reboot, because pppd is not killable, and the
kernel keeps on with this message.

Does anyone have a solution? I am completely clueless. :( I thought
about stalled sockets, but how can I destroy them?

What is blocking ppp0?

What system outputs do you need to solve this?

Cheers.


--Multipart=_Mon__24_Jan_2005_15_59_12_-0800_KNED1cU+/MA4IIE+
Content-Type: application/pgp-signature;
 name="signature.asc"
Content-Disposition: attachment;
 filename="signature.asc"
Content-Transfer-Encoding: base64

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KVmVyc2lvbjogR251UEcgdjEuMi41IChHTlUv
TGludXgpCgppRDhEQlFGQjhSVmNJMnhneG1XMHNXSVJBZ3FzQUo5bDV1R2pxcjRpYjZZa1k5VmVv
OXY0eWg5OTNnQ2dxeTJVCnhrc3NkaExlMGJuNWNqMWhiZ0lrSU04PQo9UGlUYgotLS0tLUVORCBQ
R1AgU0lHTkFUVVJFLS0tLS0KCg==

--Multipart=_Mon__24_Jan_2005_15_59_12_-0800_KNED1cU+/MA4IIE+--
