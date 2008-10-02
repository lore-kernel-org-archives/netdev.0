From: "Victor Gallardo" <vgallardo@amcc.com>
Subject: RE: [PATCH v2] ibm_newemac: Add support for GPCS, SGMIIandM88E1112 PHY
Date: Thu, 2 Oct 2008 06:40:40 -0700
Message-ID: <0CA0A16855646F4FA96D25A158E299D602C8137C@SDCEXCHANGE01.ad.amcc.com>
References: <1222929477-10329-1-git-send-email-vgallardo@amcc.com><1222929920.12264.96.camel@pasglop><0CA0A16855646F4FA96D25A158E299D602C81377@SDCEXCHANGE01.ad.amcc.com><1222932759.12264.104.camel@pasglop><20081002063320.7b2331b4@zod.rchland.ibm.com><1222943668.12264.106.camel@pasglop><20081002065648.285cce25@zod.rchland.ibm.com><20081002115507.GB2227@yoda.jdub.homelinux.org>
	<1222951068.12264.109.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1084711989=="
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
To: <benh@kernel.crashing.org>,
	"Josh Boyer" <jwboyer@linux.vnet.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============1084711989==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C92494.BDC6EDB8"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C92494.BDC6EDB8
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> Victor, while at it, can you do a fixup patch on top of it that guards
> the new feature with a Kconfig option like some of the other ones so
> that the code for it doesn't get compiled in when building, for =
example.
> for 405GP only ?
>
> The trick is to have the option not be part of the possible mask, so
> that the compiler optimises out the feature tests as if (0) (gcc
> nowadays is supposedly smart enough to rip off the code when it finds
> such constructs).

Hi Ben,=20
=20
Can you give an example of what you are asking for? I am not sure if I =
understand your request.
=20
Thanks,
=20
Victor Gallardo

------_=_NextPart_001_01C92494.BDC6EDB8
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<HTML dir=3Dltr><HEAD><TITLE>Re: [PATCH v2] ibm_newemac: Add support for =
GPCS, SGMIIandM88E1112 PHY</TITLE>=0A=
<META http-equiv=3DContent-Type content=3D"text/html; charset=3Dunicode">=0A=
<META content=3D"MSHTML 6.00.2800.1589" name=3DGENERATOR></HEAD>=0A=
<BODY>=0A=
<DIV id=3DidOWAReplyText61157 dir=3Dltr>=0A=
<DIV dir=3Dltr><FONT size=3D2><FONT face=3D"Courier New">&gt; Victor, =
while at it, can you do a fixup patch on top of it that guards<BR>&gt; =
the new feature with a Kconfig option like some of the other ones =
so<BR>&gt; that the code for it doesn't get compiled in when building, =
for example.<BR>&gt; for 405GP only ?<BR>&gt;<BR>&gt; The trick is to =
have the option not be part of the possible mask, so<BR>&gt; that the =
compiler optimises out the feature tests as if (0) (gcc<BR>&gt; nowadays =
is supposedly smart enough to rip off the code when it finds<BR>&gt; =
such constructs).<BR><BR>Hi Ben,</FONT>=0A=
<DIV dir=3Dltr>&nbsp;</DIV>=0A=
<DIV dir=3Dltr><FONT face=3D"Courier New">Can you give an example of =
what you are asking for? I am not sure if I understand your =
request.</FONT></DIV>=0A=
<DIV dir=3Dltr><FONT face=3D"Courier New"></FONT>&nbsp;</DIV>=0A=
<DIV dir=3Dltr><FONT face=3D"Courier New">Thanks,</FONT></DIV>=0A=
<DIV dir=3Dltr><FONT face=3D"Courier New"></FONT>&nbsp;</DIV>=0A=
<DIV dir=3Dltr><FONT face=3D"Courier New">Victor =
Gallardo</FONT></DIV></FONT></DIV></DIV></BODY></HTML>
------_=_NextPart_001_01C92494.BDC6EDB8--

--===============1084711989==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============1084711989==--
