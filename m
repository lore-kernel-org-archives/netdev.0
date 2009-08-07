From: "Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu>
Subject: Re: [evb] RE: [PATCH][RFC] net/bridge: add basic VEPA
	support
Date: Fri, 7 Aug 2009 14:06:58 -0700
Message-ID: <000001ca17a3$03f841f0$0be8c5d0$@edu>
References: <D2E118A1E7268F449C469EA2F301D92902BC39B2@exil.voltaire.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8492591800840360933=="
Cc: arnd@arndb.de, davem@davemloft.net, netdev@vger.kernel.org,
        bridge@lists.linux-foundation.org, adobriyan@gmail.com,
        virtualization@lists.linux-foundation.org
To: <shemminger@linux-foundation.org>, <anna.fischer@hp.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <D2E118A1E7268F449C469EA2F301D92902BC39B2@exil.voltaire.com>
Content-Language: en-us
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.

--===============8492591800840360933==
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0001_01CA1768.579969F0"
Content-Language: en-us

This is a multipart message in MIME format.

------=_NextPart_000_0001_01CA1768.579969F0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Yaron,


The interface multiplexing can be achieved using macvlan driver or using =
an SR-IOV capable NIC (the preferred option), macvlan may need to be =
extended to support VEPA multicast handling, this looks like a rather =
simple task=20

Agreed that the hardware solution is preferred so the macvlan =
implementation doesn=E2=80=99t really matter.  If we are talking SR-IOV, =
then it is direct mapped, regardless of whether there is a VEB or VEPA =
in the hardware below, so you are bypassing the bridge software code =
also. =20

I disagree that adding the multicast handling is simple =E2=80=93 while =
not conceptually hard, it will basically require you to put an address =
table into the macvlan implementation =E2=80=93 if you have that, then =
why not have just used the one already in the bridge code.  If you hook =
a VEPA up to a non-hairpin mode external bridge, you get the macvlan =
capability as well.

It also seems to me like the special macvlan interfaces for KVM =
don=E2=80=99t apply to XEN or a non-virtualized environment?  Or more =
has to be written to make that work?  If it is in the bridge code, you =
get all of this re-use.

=20

=20


------=_NextPart_000_0001_01CA1768.579969F0
Content-Type: text/html;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" =
xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=3DContent-Type content=3D"text/html; charset=3Dutf-8">
<meta name=3DGenerator content=3D"Microsoft Word 12 (filtered medium)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Verdana;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
@font-face
	{font-family:Consolas;
	panose-1:2 11 6 9 2 2 4 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
p
	{mso-style-priority:99;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
code
	{mso-style-priority:99;
	font-family:"Courier New";}
pre
	{mso-style-priority:99;
	mso-style-link:"HTML Preformatted Char";
	margin:0in;
	margin-bottom:.0001pt;
	font-size:10.0pt;
	font-family:"Courier New";}
tt
	{mso-style-priority:99;
	font-family:"Courier New";}
span.left
	{mso-style-name:left;}
span.bld
	{mso-style-name:bld;}
p.ad, li.ad, div.ad
	{mso-style-name:ad;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.ad1, li.ad1, div.ad1
	{mso-style-name:ad1;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.ad2, li.ad2, div.ad2
	{mso-style-name:ad2;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.ad3, li.ad3, div.ad3
	{mso-style-name:ad3;
	mso-margin-top-alt:auto;
	margin-right:0in;
	margin-bottom:7.5pt;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
span.HTMLPreformattedChar
	{mso-style-name:"HTML Preformatted Char";
	mso-style-priority:99;
	mso-style-link:"HTML Preformatted";
	font-family:"Consolas","serif";}
p.replbq, li.replbq, div.replbq
	{mso-style-name:replbq;
	margin:3.0pt;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
span.yshortcuts
	{mso-style-name:yshortcuts;}
p.ad4, li.ad4, div.ad4
	{mso-style-name:ad4;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.ad5, li.ad5, div.ad5
	{mso-style-name:ad5;
	mso-margin-top-alt:auto;
	margin-right:0in;
	margin-bottom:7.5pt;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.ad6, li.ad6, div.ad6
	{mso-style-name:ad6;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
span.yshortcuts1
	{mso-style-name:yshortcuts1;
	font-family:"Verdana","sans-serif";
	font-weight:bold;}
span.yshortcuts2
	{mso-style-name:yshortcuts2;
	font-family:"Verdana","sans-serif";
	font-weight:normal;}
span.EmailStyle35
	{mso-style-type:personal-reply;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:236869277;
	mso-list-template-ids:518443864;}
@list l0:level1
	{mso-level-number-format:bullet;
	mso-level-text:=EF=82=B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
-->
</style>
<!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext=3D"edit">
  <o:idmap v:ext=3D"edit" data=3D"1" />
 </o:shapelayout></xml><![endif]-->
</head>

<body bgcolor=3Dwhite lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<div style=3D'border:none;border-left:solid blue 1.5pt;padding:0in 0in =
0in 4.0pt'>

<div>

<p class=3DMsoNormal><span =
style=3D'font-size:11.0pt;font-family:"Calibri","sans-serif";
color:#1F497D'>Yaron,<o:p></o:p></span></p>

<p style=3D'margin-bottom:12.0pt'><span =
style=3D'font-size:10.0pt;font-family:"Arial","sans-serif";
color:navy'><br>
The interface multiplexing can be achieved using macvlan driver or using =
an
SR-IOV capable NIC (the preferred option), macvlan may need to be =
extended to
support VEPA multicast handling, this looks like a rather simple task =
</span><span
style=3D'font-size:10.0pt;font-family:"Arial","sans-serif";color:#1F497D'=
><o:p></o:p></span></p>

<p><span =
style=3D'font-size:11.0pt;font-family:"Calibri","sans-serif";color:#1F497=
D'>Agreed
that the hardware solution is preferred so the macvlan implementation =
doesn=E2=80=99t
really matter. &nbsp;If we are talking SR-IOV, then it is direct mapped,
regardless of whether there is a VEB or VEPA in the hardware below, so =
you are
bypassing the bridge software code also.&nbsp; <o:p></o:p></span></p>

<p><span =
style=3D'font-size:11.0pt;font-family:"Calibri","sans-serif";color:#1F497=
D'>I
disagree that adding the multicast handling is simple =E2=80=93 while =
not conceptually
hard, it will basically require you to put an address table into the =
macvlan
implementation =E2=80=93 if you have that, then why not have just used =
the one already
in the bridge code.&nbsp; If you hook a VEPA up to a non-hairpin mode =
external
bridge, you get the macvlan capability as well.<o:p></o:p></span></p>

<p><span =
style=3D'font-size:11.0pt;font-family:"Calibri","sans-serif";color:#1F497=
D'>It
also seems to me like the special macvlan interfaces for KVM =
don=E2=80=99t apply to XEN
or a non-virtualized environment?=C2=A0 Or more has to be written to =
make that
work?=C2=A0 If it is in the bridge code, you get all of this =
re-use.<o:p></o:p></span></p>

<p class=3DMsoNormal><span =
style=3D'color:white'><o:p>&nbsp;</o:p></span></p>

<p class=3DMsoNormal><span =
style=3D'font-size:11.0pt;font-family:"Calibri","sans-serif";
color:#1F497D'><o:p>&nbsp;</o:p></span></p>

</div>

</div>

</div>

</body>

</html>

------=_NextPart_000_0001_01CA1768.579969F0--


--===============8492591800840360933==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/bridge
--===============8492591800840360933==--
