From: Galy  Lee <galylee@gdnt.com.cn>
Subject: RE: how ip header added in ip_bulid_xmit function?
Date: Wed, 19 May 2004 14:27:26 +0800
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <E7AB5FC4F5C0D711B41900065BF019FB0342F9F0@rndntserver.gdnt.com.cn>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C43D6A.5A652FA8"
Cc: linuxnet <linux-net@vger.kernel.org>, netdev <netdev@oss.sgi.com>,
	netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: linux lover <linux_lover2004@yahoo.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C43D6A.5A652FA8
Content-Type: text/plain;
	charset="gb2312"


It seems that ip_build_xmit_slow is  used to send to bulk data, but the
ip_build_xmit is used to send single data packet.

-----Original Message-----
From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com]On
Behalf Of linux lover
Sent: Wednesday, May 19, 2004 2:21 PM
To: Manu Garg
Cc: linuxnet; netdev; netfilter
Subject: Re: how ip header added in ip_bulid_xmit function?




hello,

> A packet comes from TCP layer to IP layer through
> function call 
> tp->af_specific->queue_xmit() (in
> tcp_output.c:tcp_transmit_skb() ). For 
> IP this function is nothing but ip_queue_xmit()
> defined in ip_output.c.
> 
   then why ip_build_xmit and ip_build_xmit_slow used?
i think in case of ICMP packet control in icmp.c
alwayes goes to ip_build_xmit?


regards,
linux_lover


	
		
__________________________________
Do you Yahoo!?
SBC Yahoo! - Internet access at a great low price.
http://promo.yahoo.com/sbc/

------_=_NextPart_001_01C43D6A.5A652FA8
Content-Type: text/html;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dgb2312">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
5.5.2657.73">
<TITLE>RE: how ip header added in ip_bulid_xmit function?</TITLE>
</HEAD>
<BODY>
<BR>

<P><FONT SIZE=3D2>It seems that ip_build_xmit_slow is&nbsp; used to =
send to bulk data, but the&nbsp; ip_build_xmit is used to send single =
data packet.</FONT></P>

<P><FONT SIZE=3D2>-----Original Message-----</FONT>
<BR><FONT SIZE=3D2>From: netdev-bounce@oss.sgi.com [<A =
HREF=3D"mailto:netdev-bounce@oss.sgi.com">mailto:netdev-bounce@oss.sgi.c=
om</A>]On</FONT>
<BR><FONT SIZE=3D2>Behalf Of linux lover</FONT>
<BR><FONT SIZE=3D2>Sent: Wednesday, May 19, 2004 2:21 PM</FONT>
<BR><FONT SIZE=3D2>To: Manu Garg</FONT>
<BR><FONT SIZE=3D2>Cc: linuxnet; netdev; netfilter</FONT>
<BR><FONT SIZE=3D2>Subject: Re: how ip header added in ip_bulid_xmit =
function?</FONT>
</P>
<BR>
<BR>
<BR>

<P><FONT SIZE=3D2>hello,</FONT>
</P>

<P><FONT SIZE=3D2>&gt; A packet comes from TCP layer to IP layer =
through</FONT>
<BR><FONT SIZE=3D2>&gt; function call </FONT>
<BR><FONT SIZE=3D2>&gt; tp-&gt;af_specific-&gt;queue_xmit() (in</FONT>
<BR><FONT SIZE=3D2>&gt; tcp_output.c:tcp_transmit_skb() ). For </FONT>
<BR><FONT SIZE=3D2>&gt; IP this function is nothing but =
ip_queue_xmit()</FONT>
<BR><FONT SIZE=3D2>&gt; defined in ip_output.c.</FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp; then why ip_build_xmit and =
ip_build_xmit_slow used?</FONT>
<BR><FONT SIZE=3D2>i think in case of ICMP packet control in =
icmp.c</FONT>
<BR><FONT SIZE=3D2>alwayes goes to ip_build_xmit?</FONT>
</P>
<BR>

<P><FONT SIZE=3D2>regards,</FONT>
<BR><FONT SIZE=3D2>linux_lover</FONT>
</P>
<BR>

<P>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
<BR><FONT SIZE=3D2>__________________________________</FONT>
<BR><FONT SIZE=3D2>Do you Yahoo!?</FONT>
<BR><FONT SIZE=3D2>SBC Yahoo! - Internet access at a great low =
price.</FONT>
<BR><FONT SIZE=3D2><A HREF=3D"http://promo.yahoo.com/sbc/" =
TARGET=3D"_blank">http://promo.yahoo.com/sbc/</A></FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C43D6A.5A652FA8--
