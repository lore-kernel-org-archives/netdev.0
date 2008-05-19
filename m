From: Steve.Glendinning-sdUf+H5yV5I@public.gmane.org
Subject: Re: [PATCH 01/01] smsc911x: fix MAC
 addresssetting after reset
Date: Mon, 19 May 2008 13:33:11 +0100
Message-ID: <OF577965B4.463E76D4-ON8025744E.0041E1EE-8025744E.0044F4BC@smsc.com>
References: <8A42379416420646B9BFAC9682273B6D01786F29@limkexm3.ad.analog.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0492182811=="
Cc: bgat-uPd5UNENI//N9NzbbXoYwQ@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, bahadir.balban-5wv7dgnIgG8@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ian.Saturley-sdUf+H5yV5I@public.gmane.org,
        uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: "Hennerich, Michael" <Michael.Hennerich-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <8A42379416420646B9BFAC9682273B6D01786F29-pcKY8lWzTjquVPpjEGsWsTcYPEmu4y7e@public.gmane.org>
List-Unsubscribe: <http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--===============0492182811==
Content-Type: multipart/alternative;
	boundary="=_alternative 0044E7A98025744E_="

This is a multipart message in MIME format.
--=_alternative 0044E7A98025744E_=
Content-Type: text/plain; charset="US-ASCII"

Hi Michael,

I've been maintaining the smsc911x driver out-of-tree, I'll send my latest 
full patch following this email.  Bill Gatliff already fixed the same MAC 
address issue, and I've added support for the new LAN9210 and LAN9211 
devices.

(adding netdev to cc) I'd still like to see this driver replace smc911x in 
mainline, how does everyone else feel?

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning-sdUf+H5yV5I@public.gmane.org





"Hennerich, Michael" <Michael.Hennerich-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org> 
16/05/2008 11:58

To
"Enrik Berkhan" <Enrik.Berkhan-JJi787mZWgc@public.gmane.org>, Steve Glendinning/SMSC@SMSC
cc
<hennerich-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>, Ian Saturley/SMSC@SMSC, 
<uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>, <bahadir.balban-5wv7dgnIgG8@public.gmane.org>, 
<bgat-uPd5UNENI//N9NzbbXoYwQ@public.gmane.org>
Subject
RE: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC addresssetting 
after reset






Hi Steve,

I received a patch to address the MAC address soft reset issue,
discussed before.

Is there a newer driver with this and maybe other fixes?

Some time ago I thought this driver is going to be mainlined.
Are you still panning to get it merged, - replace smc911x.c.

-Michael

>-----Original Message-----
>From: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
[mailto:uclinux-dist-
>devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org] On Behalf Of Enrik Berkhan
>Sent: Donnerstag, 15. Mai 2008 19:08
>To: uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
>Subject: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC
>addresssetting after reset
>
>The SMSC911X driver soft-resets the chip on open(). This makes the
>chip forget and re-load its MAC address from its EEPROM, if avail-
>able.
>
>If the MAC address has been set externally (e. g. by the bootloader
>or via command line), this setting is lost. This patch fixes the
>problem by always setting the saved MAC address after soft reset.
>
>Signed-Off-By: Enrik Berkhan <Enrik.Berkhan-JJi787mZWgc@public.gmane.org>
>---
> drivers/net/smsc911x.c |    4 ++++
> 1 file changed, 4 insertions(+)
>
>Index: drivers/net/smsc911x.c
>===================================================================
>--- drivers/net/smsc911x.c.orig                 2008-05-15 
18:49:30.000000000
+0200
>+++ drivers/net/smsc911x.c              2008-05-15 18:51:28.000000000 
+0200
>@@ -1182,6 +1182,10 @@ static int smsc911x_open(struct net_devi
>                                udelay(10);
>                }
>
>+               /* Set MAC again in case it has been set from non-EEPROM 
source
>+                * (config or even bootloader) */
>+               smsc911x_set_mac_address(pdata, dev->dev_addr);
>+
>                if (unlikely(timeout == 0)) {
>                                SMSC_WARNING("Timed out waiting for 
EEPROM "
>                                                     "busy bit to 
clear");
>_______________________________________________
>Uclinux-dist-devel mailing list
>Uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
>http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel


--=_alternative 0044E7A98025744E_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2 face="sans-serif">Hi Michael,</font>
<br>
<br><font size=2 face="sans-serif">I've been maintaining the smsc911x driver
out-of-tree, I'll send my latest full patch following this email. &nbsp;Bill
Gatliff already fixed the same MAC address issue, and I've added support
for the new LAN9210 and LAN9211 devices.</font>
<br>
<br><font size=2 face="sans-serif">(adding netdev to cc) I'd still like
to see this driver replace smc911x in mainline, how does everyone else
feel?</font>
<br>
<br><font size=2 face="sans-serif">Regards,</font>
<br><font size=2 face="sans-serif">--<br>
Steve Glendinning<br>
SMSC GmbH<br>
m: +44 777 933 9124<br>
e: steve.glendinning-sdUf+H5yV5I@public.gmane.org<br>
<br>
</font>
<br>
<br>
<br>
<table width=100%>
<tr valign=top>
<td width=40%><font size=1 face="sans-serif"><b>&quot;Hennerich, Michael&quot;
&lt;Michael.Hennerich-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org&gt;</b> </font>
<p><font size=1 face="sans-serif">16/05/2008 11:58</font>
<td width=59%>
<table width=100%>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">To</font></div>
<td><font size=1 face="sans-serif">&quot;Enrik Berkhan&quot; &lt;Enrik.Berkhan-JJi787mZWgc@public.gmane.org&gt;,
Steve Glendinning/SMSC@SMSC</font>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">cc</font></div>
<td><font size=1 face="sans-serif">&lt;hennerich-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org&gt;,
Ian Saturley/SMSC@SMSC, &lt;uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org&gt;,
&lt;bahadir.balban-5wv7dgnIgG8@public.gmane.org&gt;, &lt;bgat-uPd5UNENI//N9NzbbXoYwQ@public.gmane.org&gt;</font>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">Subject</font></div>
<td><font size=1 face="sans-serif">RE: [Uclinux-dist-devel] [PATCH 01/01]
smsc911x: fix MAC addresssetting after reset</font></table>
<br>
<table>
<tr valign=top>
<td>
<td></table>
<br></table>
<br>
<br>
<br><tt><font size=2>Hi Steve,<br>
<br>
I received a patch to address the MAC address soft reset issue,<br>
discussed before.<br>
<br>
Is there a newer driver with this and maybe other fixes?<br>
<br>
Some time ago I thought this driver is going to be mainlined.<br>
Are you still panning to get it merged, - replace smc911x.c.<br>
<br>
-Michael<br>
<br>
&gt;-----Original Message-----<br>
&gt;From: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org<br>
[mailto:uclinux-dist-<br>
&gt;devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org] On Behalf Of Enrik Berkhan<br>
&gt;Sent: Donnerstag, 15. Mai 2008 19:08<br>
&gt;To: uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org<br>
&gt;Subject: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC<br>
&gt;addresssetting after reset<br>
&gt;<br>
&gt;The SMSC911X driver soft-resets the chip on open(). This makes the<br>
&gt;chip forget and re-load its MAC address from its EEPROM, if avail-<br>
&gt;able.<br>
&gt;<br>
&gt;If the MAC address has been set externally (e. g. by the bootloader<br>
&gt;or via command line), this setting is lost. This patch fixes the<br>
&gt;problem by always setting the saved MAC address after soft reset.<br>
&gt;<br>
&gt;Signed-Off-By: Enrik Berkhan &lt;Enrik.Berkhan-JJi787mZWgc@public.gmane.org&gt;<br>
&gt;---<br>
&gt; drivers/net/smsc911x.c | &nbsp; &nbsp;4 ++++<br>
&gt; 1 file changed, 4 insertions(+)<br>
&gt;<br>
&gt;Index: drivers/net/smsc911x.c<br>
&gt;===================================================================<br>
&gt;--- drivers/net/smsc911x.c.orig &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; 2008-05-15 18:49:30.000000000<br>
+0200<br>
&gt;+++ drivers/net/smsc911x.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; 2008-05-15 18:51:28.000000000 +0200<br>
&gt;@@ -1182,6 +1182,10 @@ static int smsc911x_open(struct net_devi<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
udelay(10);<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;}<br>
&gt;<br>
&gt;+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
/* Set MAC again in case it has been set from non-EEPROM source<br>
&gt;+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp;* (config or even bootloader) */<br>
&gt;+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
smsc911x_set_mac_address(pdata, dev-&gt;dev_addr);<br>
&gt;+<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;if
(unlikely(timeout == 0)) {<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
SMSC_WARNING(&quot;Timed out waiting for EEPROM &quot;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &quot;busy bit to clear&quot;);<br>
&gt;_______________________________________________<br>
&gt;Uclinux-dist-devel mailing list<br>
&gt;Uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org<br>
&gt;http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel<br>
</font></tt>
<br>
--=_alternative 0044E7A98025744E_=--

--===============0492182811==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Uclinux-dist-devel mailing list
Uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel
--===============0492182811==--
