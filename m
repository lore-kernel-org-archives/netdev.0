From: "Paul Smith" <psmith@netezza.com>
Subject: NET_POLL missing in the new ibm_emac driver?
Date: Mon, 9 Apr 2007 12:53:22 -0400
Message-ID: <1176137602.30046.191.camel@psmithub>
Reply-To: Paul Smith <psmith@netezza.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0487299858=="
Cc: netdev@vger.kernel.org
To: <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============0487299858==
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C77AC7.95ACDE53"
Content-class: urn:content-classes:message

This is a multi-part message in MIME format.

------_=_NextPart_001_01C77AC7.95ACDE53
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I was having so many problems with the 2.6.14 (old) emac driver that I
backported the new one from 2.6.15.  It works great... until I tried to
use KGDBOE with it.  Then I got:

    kgdboe: eth1 doesn't support polling, aborting.

Looking around I see that I need the driver to support the
poll_controller method in the net device, and the new driver doesn't
seem to do that.

I see the old implementation of this method, but of course it uses
interfaces that no longer exist so I can't use that directly.  It seems
like a small change but I'm not really familiar with the implementation
of the ibm_emac driver; does anyone have a patch for the new driver to
provide this feature?


Thanks!

--=20
-------------------------------------------------------------------------=
----
 Paul D. Smith <psmith@netezza.com>                       =
http://netezza.com
 "Please remain calm--I may be mad, but I am a professional."--Mad =
Scientist
-------------------------------------------------------------------------=
----
      These are my opinions--Netezza takes no responsibility for them.

------_=_NextPart_001_01C77AC7.95ACDE53
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7651.59">
<TITLE>NET_POLL missing in the new ibm_emac driver?</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->

<P><FONT SIZE=3D2>I was having so many problems with the 2.6.14 (old) =
emac driver that I<BR>
backported the new one from 2.6.15.&nbsp; It works great... until I =
tried to<BR>
use KGDBOE with it.&nbsp; Then I got:<BR>
<BR>
&nbsp;&nbsp;&nbsp; kgdboe: eth1 doesn't support polling, aborting.<BR>
<BR>
Looking around I see that I need the driver to support the<BR>
poll_controller method in the net device, and the new driver doesn't<BR>
seem to do that.<BR>
<BR>
I see the old implementation of this method, but of course it uses<BR>
interfaces that no longer exist so I can't use that directly.&nbsp; It =
seems<BR>
like a small change but I'm not really familiar with the =
implementation<BR>
of the ibm_emac driver; does anyone have a patch for the new driver =
to<BR>
provide this feature?<BR>
<BR>
<BR>
Thanks!<BR>
<BR>
--<BR>
-------------------------------------------------------------------------=
----<BR>
&nbsp;Paul D. Smith =
&lt;psmith@netezza.com&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; <A HREF=3D"http://netezza.com">http://netezza.com</A><BR>
&nbsp;&quot;Please remain calm--I may be mad, but I am a =
professional.&quot;--Mad Scientist<BR>
-------------------------------------------------------------------------=
----<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; These are my opinions--Netezza takes no =
responsibility for them.<BR>
</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C77AC7.95ACDE53--

--===============0487299858==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-embedded mailing list
Linuxppc-embedded@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-embedded
--===============0487299858==--
