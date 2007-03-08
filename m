From: "Hai Wang" <hwang@finepoint.com>
Subject: brctl issue
Date: Wed, 7 Mar 2007 22:30:09 -0500
Message-ID: <DE026503646E7F40AF97BAB98334333B267A1B@uss-republic.finepoint.com>
References: <20070307160355.0e27f425@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0302758750=="
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <bridge-bounces@lists.osdl.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format...

--===============0302758750==
Content-Type: multipart/alternative;
    boundary="----------=_1173324657-6688-351"
Content-Transfer-Encoding: binary
MIME-Version: 1.0
X-Mailer: MIME-tools 5.411 (Entity 5.404)

This is a multi-part message in MIME format...

------------=_1173324657-6688-351
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,
=20
     I have a question regarding brctl and br2684, I have a network scenrio=
 where I have to add br2684-rt into a bridge. but I could not do so with br=
ctl, please let me if you have any suggestion on the issue.
=20
My scenario :
=20
                                       (vpi/vci)=20
      192.168.2.16             0/32               nas0
    DSLAM1 (BR2684-rt)  --------------|-----------------
       192.168.3.26            0/33                |                       =
  |                                    192.168.1.18
    DSLAM 2(BR2684-rt)  --------------| nas1 (LINUX)  Eth0     ------------=
-----PC1 (OAM)
        192.168.4.36            0/34               |                       =
  |
    DSLAM 3(BR2684-rt)  --------------|nas2------------
=20
=20
    I want to put nas0, nas1, nas2 and eth0 on a bridge so that PC1 is able=
 to communicate with DSLAMS.
=20
=20
  Note that we do not want to assign any IP on nas0, nas1 and nas2.
=20
=20
Please help with your suggestion.
=20
=20
HAI
=20
=20
=20
=20=20

------------=_1173324657-6688-351
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<HTML dir=3Dltr><HEAD><TITLE>[Bridge] [PATCH] bridge: adding new device to =
bridge should enableif up</TITLE>
<META http-equiv=3DContent-Type content=3D"text/html; charset=3Dunicode">
<META content=3D"MSHTML 6.00.6000.16414" name=3DGENERATOR></HEAD>
<BODY>
<DIV id=3DidOWAReplyText52168 dir=3Dltr>
<DIV dir=3Dltr>Hello,</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp;&nbsp;&nbsp;&nbsp; I have a question regarding brctl a=
nd br2684, I have a network scenrio where I have to add br2684-rt into a br=
idge. but I could not do&nbsp;so with brctl, please let me if you have any =
suggestion on the issue.</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>My scenario :</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;(vpi/vci)&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;192.168.2.16&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0/32&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;nas0</DIV>
<DIV dir=3Dltr>&nbsp;&nbsp;&nbsp; DSLAM1 (BR2684-rt)&nbsp; --------------|-=
----------------</DIV>
<DIV dir=3Dltr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;192.168.3.26&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0/33&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;=
 |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;192.168.1.1=
8</DIV>
<DIV dir=3Dltr>&nbsp;&nbsp;&nbsp;&nbsp;DSLAM 2(BR2684-rt)&nbsp; -----------=
---|&nbsp;nas1&nbsp;(LINUX)&nbsp;&nbsp;Eth0&nbsp;&nbsp;&nbsp;&nbsp; -------=
----------PC1 (OAM)</DIV>
<DIV dir=3Dltr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;192.168.4.36=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;0/34&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; |</DIV>
<DIV dir=3Dltr>&nbsp;&nbsp;&nbsp; DSLAM 3(BR2684-rt)&nbsp; --------------|n=
as2------------</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp;&nbsp;&nbsp; I want to put nas0, nas1, nas2 and eth0 o=
n&nbsp;a bridge so that PC1 is able to communicate with DSLAMS.</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp; Note that we do not want to assign any IP on nas0, na=
s1 and nas2.</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>Please help with&nbsp;your suggestion.</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>HAI</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp;</DIV>
<DIV dir=3Dltr>&nbsp;&nbsp;</DIV></DIV></BODY></HTML>
------------=_1173324657-6688-351--

--===============0302758750==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
https://lists.osdl.org/mailman/listinfo/bridge

--===============0302758750==--
