From: Stephen Clark <sclark46-ihVZJaRskl1bRRN4PJnoQQ@public.gmane.org>
Subject: Re: ipsec tunnel with different inner and outer
 ip	families
Date: Fri, 13 Jan 2012 09:04:53 -0500
Message-ID: <4F103A05.3050802@earthlink.net>
References: <B97B134FACB2024DB45F524AB0A7B7F2058AF974@XMB-BGL-419.cisco.com>
Reply-To: sclark46-ihVZJaRskl1bRRN4PJnoQQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6235668505110760934=="
Cc: ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Prashant Batra (prbatra)" <prbatra-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <ipsec-tools-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <B97B134FACB2024DB45F524AB0A7B7F2058AF974-rRFx+brps5guW2sxTbe+i6BKnGwkPULj@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel>,
	<mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipsec-tools-devel>
List-Post: <mailto:ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel>,
	<mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: ipsec-tools-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============6235668505110760934==
Content-Type: multipart/alternative;
	boundary="------------070809070700020809070200"

This is a multi-part message in MIME format.
--------------070809070700020809070200
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I couldn't get it to work either. So I made and ipv4 in ipv6 tunnel, 
then did an ipv4 to ipv4 ipsec tunnel inside of ipv4-in-ipv6 tunnel.
Then gre inside of ipv4 ipsec tunnel so I could run OSPF - works great.

HTH,
Steve

On 01/13/2012 02:11 AM, Prashant Batra (prbatra) wrote:
>
> Hello,
>
> Does linux 2.6.* support an IPSec tunnel with different family of 
> inner and outer addresses , like v4 in v6 or v6 in v4.
>
> After trying ip xfrm * from user space, the utility doesn't seem to 
> accept two different families in a single command.
>
> #ip xfrm policy add dir out src 172.168.68.1/32 dst 172.168.68.2/32 
> tmpl src 2001:db8:0:242::36/128 dst 2001:db8:0:242::37/128 proto esp  
> mode tunnel
>
> Error: an inet prefix is expected rather than "2001:db8:0:242::36/128".
>
> So, I tried sending a NETLINK SPD add message) from user space with, 
> selector as v4 addresses and tmpl as v6 address.
>
> Policy got added but kernel doesn't seem to be interpreting the 
> addresses correctly.
>
> src 172.16.80.1/32 dst 0.0.0.0/0
>
>         dir out priority 1024
>
>         tmpl    src 32.1.13.184 dst 32.1.13.184   /* I gave ipv6 
> addresses here*/
>
>                 proto esp spi 0x00000000 reqid 0 mode tunnel
>
> Can someone help me with this?
>
> Regards,
>
> Prashant.
>
>
> ------------------------------------------------------------------------------
> RSA(R) Conference 2012
> Mar 27 - Feb 2
> Save $400 by Jan. 27
> Register now!
> http://p.sf.net/sfu/rsa-sfdev2dev2
>
>
> _______________________________________________
> Ipsec-tools-devel mailing list
> Ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel
>    


-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)




--------------070809070700020809070200
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html; charset=ISO-8859-1"
 http-equiv="Content-Type">
  <title></title>
</head>
<body bgcolor="#ffffff" text="#000000">
Hi,<br>
<br>
I couldn't get it to work either. So I made and ipv4 in ipv6 tunnel,
then did an ipv4 to ipv4 ipsec tunnel inside of ipv4-in-ipv6 tunnel.<br>
Then gre inside of ipv4 ipsec tunnel so I could run OSPF - works great.<br>
<br>
HTH,<br>
Steve<br>
<br>
On 01/13/2012 02:11 AM, Prashant Batra (prbatra) wrote:
<blockquote
 cite="mid:B97B134FACB2024DB45F524AB0A7B7F2058AF974-rRFx+brps5guW2sxTbe+i6BKnGwkPULj@public.gmane.org"
 type="cite">
  <meta http-equiv="Content-Type"
 content="text/html; charset=ISO-8859-1">
  <meta name="Generator" content="Microsoft Word 12 (filtered medium)">
  <style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.Section1
	{page:Section1;}
-->
  </style>
<!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1" />
 </o:shapelayout></xml><![endif]-->
  <div class="Section1">
  <p class="MsoNormal">Hello,<o:p></o:p></p>
  <p class="MsoNormal"><o:p>&nbsp;</o:p></p>
  <p class="MsoNormal">Does linux 2.6.* support an IPSec tunnel with
different
family of inner and outer addresses , like v4 in v6 or v6 in v4.<o:p></o:p></p>
  <p class="MsoNormal">After trying ip xfrm * from user space, the
utility doesn&#8217;t
seem to accept two different families in a single command.<o:p></o:p></p>
  <p class="MsoNormal"><o:p>&nbsp;</o:p></p>
  <p class="MsoNormal">#ip xfrm policy add dir out src 172.168.68.1/32
dst
172.168.68.2/32 tmpl src 2001:db8:0:242::36/128 dst
2001:db8:0:242::37/128
proto esp&nbsp; mode tunnel<o:p></o:p></p>
  <p class="MsoNormal">Error: an inet prefix is expected rather than
"2001:db8:0:242::36/128".<o:p></o:p></p>
  <p class="MsoNormal"><o:p>&nbsp;</o:p></p>
  <p class="MsoNormal">So, I tried sending a NETLINK SPD add message)
from user
space with, selector as v4 addresses and tmpl as v6 address.<o:p></o:p></p>
  <p class="MsoNormal">Policy got added but kernel doesn&#8217;t seem to be
interpreting
the addresses correctly.<o:p></o:p></p>
  <p class="MsoNormal"><o:p>&nbsp;</o:p></p>
  <p class="MsoNormal">src 172.16.80.1/32 dst 0.0.0.0/0<o:p></o:p></p>
  <p class="MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dir out priority
1024<o:p></o:p></p>
  <p class="MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tmpl&nbsp;&nbsp;&nbsp; src 32.1.13.184 dst 32.1.13.184&nbsp;&nbsp; /* I gave
ipv6 addresses here*/<o:p></o:p></p>
  <p class="MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
proto esp spi 0x00000000 reqid 0 mode tunnel<o:p></o:p></p>
  <p class="MsoNormal"><o:p>&nbsp;</o:p></p>
  <p class="MsoNormal">Can someone help me with this?<o:p></o:p></p>
  <p class="MsoNormal"><o:p>&nbsp;</o:p></p>
  <p class="MsoNormal">Regards,<o:p></o:p></p>
  <p class="MsoNormal">Prashant.<o:p></o:p></p>
  </div>
  <pre wrap="">
<fieldset class="mimeAttachmentHeader"></fieldset>
------------------------------------------------------------------------------
RSA(R) Conference 2012
Mar 27 - Feb 2
Save $400 by Jan. 27
Register now!
<a class="moz-txt-link-freetext" href="http://p.sf.net/sfu/rsa-sfdev2dev2">http://p.sf.net/sfu/rsa-sfdev2dev2</a></pre>
  <pre wrap="">
<fieldset class="mimeAttachmentHeader"></fieldset>
_______________________________________________
Ipsec-tools-devel mailing list
<a class="moz-txt-link-abbreviated" href="mailto:Ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org">Ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org</a>
<a class="moz-txt-link-freetext" href="https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel">https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel</a>
  </pre>
</blockquote>
<br>
<br>
<pre class="moz-signature" cols="80">-- 

"They that give up essential liberty to obtain temporary safety, 
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty 
decreases."  (Thomas Jefferson)


</pre>
</body>
</html>

--------------070809070700020809070200--


--===============6235668505110760934==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
RSA(R) Conference 2012
Mar 27 - Feb 2
Save $400 by Jan. 27
Register now!
http://p.sf.net/sfu/rsa-sfdev2dev2
--===============6235668505110760934==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============6235668505110760934==--
