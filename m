From: Chad Hanson <chanson@TrustedCS.com>
Subject: RE: [PATCH] Add audit uid to netlink credentials
Date: Thu, 10 Feb 2005 10:16:21 -0500
Message-ID: <36282A1733C57546BE392885C06185927377E6@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: kuznet@ms2.inr.ac.ru, davem@davemloft.net, netdev@oss.sgi.com
To: Linux Audit Discussion <linux-audit@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David Woodhouse wrote:
>=20
> Perhaps I misunderstand the intent of userspace AUDIT_WRITE. Can you
> provide examples of why you _wouldn't_ want to let a d=C3=A6mon which i=
s
> already sending random unvetted AUDIT_WRITE messages also specify the
> loginuid on _those_ messages?

The loginuid is part of the process state. This is the reason you do not
want to write out this information from a userspace application, as the
process state portions of the audit record are recorded by the kernel.=20

-Chad
