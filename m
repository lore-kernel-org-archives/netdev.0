From: Shibu LKML <shibu_lkml@yahoo.com>
Subject: Disconnecting a connected UDP socket
Date: Wed, 2 Jul 2003 20:16:10 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030703031610.79050.qmail@web20704.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-572335396-1057202170=:79043"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0-572335396-1057202170=:79043
Content-Type: text/plain; charset=us-ascii

Hi,
 
I am wondering if Linux supports disconnecting a connected UDP socket. The manpage for connect lists it in the BUGS section. It says disconnect is still not supported. I was wondering if it involves more than adding the following lines to udp_connect in udp.c
 
if (usin->sin_family == AF_UNSPEC)
  return udp_disconnect(sk, 0);

(just  above sk_dst_reset(sk))
 
Will this fix the problem for IPV4 stuff? 
 
 
Regards
Shibu
 


---------------------------------
Do you Yahoo!?
SBC Yahoo! DSL - Now only $29.95 per month!
--0-572335396-1057202170=:79043
Content-Type: text/html; charset=us-ascii

<DIV>Hi,</DIV>
<DIV>&nbsp;</DIV>
<DIV>I am wondering if Linux supports disconnecting a connected UDP socket. The manpage for connect lists it in the BUGS section. It says disconnect is still not supported. I was wondering if it involves more than adding the following lines to udp_connect in udp.c</DIV>
<DIV>&nbsp;</DIV>
<DIV><STRONG>if (usin-&gt;sin_family == AF_UNSPEC)<BR>&nbsp;&nbsp;return udp_disconnect(sk, 0);<BR></STRONG></DIV>
<DIV><STRONG>(just&nbsp; above sk_dst_reset(sk))</STRONG></DIV>
<DIV><STRONG></STRONG>&nbsp;</DIV>
<DIV>Will this fix the problem for IPV4 stuff? </DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>Regards</DIV>
<DIV>Shibu</DIV>
<DIV>&nbsp;</DIV><p><hr SIZE=1>
Do you Yahoo!?<br>
<a href="http://pa.yahoo.com/*http://rd.yahoo.com/evt=1207/*http://promo.yahoo.com/sbc/">SBC Yahoo! DSL</a> - Now only $29.95 per month!
--0-572335396-1057202170=:79043--
