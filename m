From: "Fritz, Wolfgang" <Wolfgang.Fritz@keymile.com>
Subject: Re: [PATCH] net,
	bridge: print log message after state changed
Date: Mon, 14 Nov 2011 08:03:31 +0100
Message-ID: <1321254211.4072.29.camel@pc005091.de.keymile.net>
References: <1320941934-3534-1-git-send-email-holger.brunck@keymile.com>
	<20111114.003702.1097206603722725705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1362143575534058751=="
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, "Brunck,
	Holger" <holger.brunck@keymile.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-class: urn:content-classes:message
In-Reply-To: <20111114.003702.1097206603722725705.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============1362143575534058751==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01CCA29B.843E701A"

This is a multi-part message in MIME format.

------_=_NextPart_001_01CCA29B.843E701A
Content-Type: text/plain;
	charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable


Am Montag, den 14.11.2011, 00:37 -0500 schrieb David Miller:
> From: Holger Brunck <holger.brunck@keymile.com>
> Date: Thu, 10 Nov 2011 17:18:54 +0100
>=20
> > From: Wolfgang Fritz <wolfgang.fritz@keymile.com>
> >=20
> > Function br_log_state writes log message "... entering XXXX state" =
so it
> > should be called after the state has changed and not before.
> >=20
> > Signed-off-by: Wolfgang Fritz <wolfgang.fritz@keymile.com>
> > Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
>=20
> "entering" can roughly mean "about to enter"
>=20

Exactly.

> The message is therefore appropriately timed as far as I'm concerned.
>=20

It's not.

Please test: create a bridge with STP disabled, add an interface to the
bridge and set that interface down. You get the message "... entering
forwarding state". That's wrong because it's "about to enter" disabled
state some lines later.

All other (4) calls to br_log_state are located after the state change,
see for example br_stp_enable_port() just some lines above the patch.

Regards,
Wolfgang=20


> I'm not applying this patch.
>=20
--=20
"I love deadlines. I like the whooshing sound they make as they fly by"
(Douglas Adams)
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
KEYMILE GmbH       mailto:wolfgang.fritz@keymile.com
Wolfgang Fritz     Phone: +49 (0)511 6747-692
Wohlenbergstr. 3   Fax:   +49 (0)511 6747-777
D-30179 Hannover   http://www.keymile.com

Managing Directors: Bj=F6rn Claa=DFen, Dipl.-Kfm. Andreas Gebauer
Legal structure: GmbH, Registered office: Hanover, HRB 61069=20
Local court Hanover, VAT-Reg.-No.: DE 812282795,=20
WEEE-Reg.-No.: DE 59336750

------_=_NextPart_001_01CCA29B.843E701A
Content-Type: text/html;
	charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-15">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7651.59">
<TITLE>Re: [PATCH] net, bridge: print log message after state =
changed</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->
<BR>

<P><FONT SIZE=3D2>Am Montag, den 14.11.2011, 00:37 -0500 schrieb David =
Miller:<BR>
&gt; From: Holger Brunck &lt;holger.brunck@keymile.com&gt;<BR>
&gt; Date: Thu, 10 Nov 2011 17:18:54 +0100<BR>
&gt;<BR>
&gt; &gt; From: Wolfgang Fritz &lt;wolfgang.fritz@keymile.com&gt;<BR>
&gt; &gt;<BR>
&gt; &gt; Function br_log_state writes log message &quot;... entering =
XXXX state&quot; so it<BR>
&gt; &gt; should be called after the state has changed and not =
before.<BR>
&gt; &gt;<BR>
&gt; &gt; Signed-off-by: Wolfgang Fritz =
&lt;wolfgang.fritz@keymile.com&gt;<BR>
&gt; &gt; Signed-off-by: Holger Brunck =
&lt;holger.brunck@keymile.com&gt;<BR>
&gt;<BR>
&gt; &quot;entering&quot; can roughly mean &quot;about to =
enter&quot;<BR>
&gt;<BR>
<BR>
Exactly.<BR>
<BR>
&gt; The message is therefore appropriately timed as far as I'm =
concerned.<BR>
&gt;<BR>
<BR>
It's not.<BR>
<BR>
Please test: create a bridge with STP disabled, add an interface to =
the<BR>
bridge and set that interface down. You get the message &quot;... =
entering<BR>
forwarding state&quot;. That's wrong because it's &quot;about to =
enter&quot; disabled<BR>
state some lines later.<BR>
<BR>
All other (4) calls to br_log_state are located after the state =
change,<BR>
see for example br_stp_enable_port() just some lines above the =
patch.<BR>
<BR>
Regards,<BR>
Wolfgang<BR>
<BR>
<BR>
&gt; I'm not applying this patch.<BR>
&gt;<BR>
--<BR>
&quot;I love deadlines. I like the whooshing sound they make as they fly =
by&quot;<BR>
(Douglas Adams)<BR>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<BR>
KEYMILE GmbH&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <A =
HREF=3D"mailto:wolfgang.fritz@keymile.com">mailto:wolfgang.fritz@keymile.=
com</A><BR>
Wolfgang Fritz&nbsp;&nbsp;&nbsp;&nbsp; Phone: +49 (0)511 6747-692<BR>
Wohlenbergstr. 3&nbsp;&nbsp; Fax:&nbsp;&nbsp; +49 (0)511 6747-777<BR>
D-30179 Hannover&nbsp;&nbsp; <A =
HREF=3D"http://www.keymile.com">http://www.keymile.com</A><BR>
<BR>
Managing Directors: Bj=F6rn Claa=DFen, Dipl.-Kfm. Andreas Gebauer<BR>
Legal structure: GmbH, Registered office: Hanover, HRB 61069<BR>
Local court Hanover, VAT-Reg.-No.: DE 812282795,<BR>
WEEE-Reg.-No.: DE 59336750<BR>
</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01CCA29B.843E701A--

--===============1362143575534058751==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/bridge
--===============1362143575534058751==--
