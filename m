From: =?gb2312?q?minnie=20wu?= <minniewkitty@yahoo.com.cn>
Subject: Re: How to improve small packet performance
Date: Thu, 14 Aug 2003 10:31:21 +0800 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030814023121.80893.qmail@web15212.mail.bjs.yahoo.com>
References: <1060835023.3f3b0ecfc97b4@webmail.katalix.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-907308067-1060828281=:80393"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jchapman@katalix.com
In-Reply-To: <1060835023.3f3b0ecfc97b4@webmail.katalix.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0-907308067-1060828281=:80393
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id h7E2WkFl031348

   Here is the experimental setup I used:
   A traffic generator[Smartbits] is sending from one of its ports to the=
 PC on eth0. Linux routes the packet out eth1 back to the Smartbits. /pro=
c/sys/net/ipv4/ip_forward set to 1.
  The PC is a PIII 863MHz with 256M of RAM. And the NIC cards do not shar=
e the same irq.
  The unidirectional test:
   e100-v3.0.0dev12-napi    47k packets/sec
   eepro100-napi-020619     89k packets/sec
  =20
  minnie
jchapman@katalix.com wrote:I downloaded the eepro100 NAPI patch and tried=
 it in my test setup (a
1GHz P-III configured as a 2-port bridge, 2.4.20-8 RH9 kernel). I see
e100-napi perform much better than eepro100, which is what I was=20
expecting

e100-v3.0.0dev12-napi 93k packets/sec
eepro100-napi-020619 49k packets/sec

When doing a bidirectional test, the eepro100 driver locks up
completely, although it seems to survive with 128 byte packets (where
the event rate is less).

What's your test setup? How are you generating your test traffic? Do
your NIC cards share the same irq?

-jc



---------------------------------
Do You Yahoo!?
=CA=EE=C6=DA=B4=F3=C6=AC=C6=EB=BE=DB=D1=C5=BB=A2=CD=A8 =CD=F8=C2=E7=C9=E3=
=CF=F1=CD=B7+=D1=C5=BB=A2=CD=A8=B5=F7=C6=B5=CA=D5=D2=F4=BB=FA=B5=C8=C4=E3=
=C0=B4=C4=C3
--0-907308067-1060828281=:80393
Content-Type: text/html; charset=gb2312
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id h7E2WkFl031348

<DIV>&nbsp;&nbsp; Here is the experimental setup I used:<BR>&nbsp;&nbsp; =
A traffic generator[Smartbits] is sending from one of its ports to the PC=
 on eth0. Linux routes the packet out eth1 back to the Smartbits. /proc/s=
ys/net/ipv4/ip_forward set to 1.<BR>&nbsp; The PC is a PIII 863MHz with 2=
56M of RAM. And the NIC cards do not share the same irq.<BR>&nbsp; The un=
idirectional test:<BR>&nbsp;&nbsp; e100-v3.0.0dev12-napi&nbsp;&nbsp;&nbsp=
; 47k packets/sec<BR>&nbsp;&nbsp; eepro100-napi-020619&nbsp;&nbsp;&nbsp;&=
nbsp; 89k packets/sec<BR>&nbsp;&nbsp; <BR>&nbsp; minnie<BR><B><I>jchapman=
@katalix.com</I></B> wrote:
<BLOCKQUOTE style=3D"PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #1=
010ff 2px solid; WIDTH: 100%">I downloaded the eepro100 NAPI patch and tr=
ied it in my test setup (a<BR>1GHz P-III configured as a 2-port bridge, 2=
.4.20-8 RH9 kernel). I see<BR>e100-napi perform much better than eepro100=
, which is what I was <BR>expecting<BR><BR>e100-v3.0.0dev12-napi 93k pack=
ets/sec<BR>eepro100-napi-020619 49k packets/sec<BR><BR>When doing a bidir=
ectional test, the eepro100 driver locks up<BR>completely, although it se=
ems to survive with 128 byte packets (where<BR>the event rate is less).<B=
R><BR>What's your test setup? How are you generating your test traffic? D=
o<BR>your NIC cards share the same irq?<BR><BR>-jc</BLOCKQUOTE></DIV><p><=
br><hr size=3D1><b>Do You Yahoo!?</b><br>
<a href=3D"http://cn.rd.yahoo.com/mail_cn/tag/?http://cn.promo.yahoo.com/=
minisite/messenger1/" target=3Dblank>=CA=EE=C6=DA=B4=F3=C6=AC=C6=EB=BE=DB=
=D1=C5=BB=A2=CD=A8 =CD=F8=C2=E7=C9=E3=CF=F1=CD=B7+=D1=C5=BB=A2=CD=A8=B5=F7=
=C6=B5=CA=D5=D2=F4=BB=FA=B5=C8=C4=E3=C0=B4=C4=C3</a>
--0-907308067-1060828281=:80393--
