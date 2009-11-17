From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: net-next-2.6 compilation errors: missing wireless/i82593.h
Date: Tue, 17 Nov 2009 06:34:15 -0500
Message-ID: <4B028A37.1010202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:63902 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbZKQLeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 06:34:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46or the past 9-10 days, net-next-2.6 has failed to compile.  In addit=
ion to
the errors and warnings already reported here last week, since Nov 12th
there has been another missing file.  I kept hoping it was temporary, b=
ut
no joy.

/home/administer/net-next-2.6/drivers/net/znet.c:107:29: error: wireles=
s/i82593.h: No such file or directory
/home/administer/net-next-2.6/drivers/net/znet.c:133: error: field =91i=
593_init=92 has incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c: In function =91znet_s=
et_multicast_list=92:
/home/administer/net-next-2.6/drivers/net/znet.c:235: error: invalid ap=
plication of =91sizeof=92 to incomplete type =91struct i82593_conf_bloc=
k=92
/home/administer/net-next-2.6/drivers/net/znet.c:235: error: invalid ap=
plication of =91sizeof=92 to incomplete type =91struct i82593_conf_bloc=
k=92
/home/administer/net-next-2.6/drivers/net/znet.c:235: error: invalid ap=
plication of =91sizeof=92 to incomplete type =91struct i82593_conf_bloc=
k=92
/home/administer/net-next-2.6/drivers/net/znet.c:235: error: invalid ap=
plication of =91sizeof=92 to incomplete type =91struct i82593_conf_bloc=
k=92
/home/administer/net-next-2.6/drivers/net/znet.c:235: error: invalid ap=
plication of =91sizeof=92 to incomplete type =91struct i82593_conf_bloc=
k=92
/home/administer/net-next-2.6/drivers/net/znet.c:235: error: invalid ap=
plication of =91sizeof=92 to incomplete type =91struct i82593_conf_bloc=
k=92
/home/administer/net-next-2.6/drivers/net/znet.c:247: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:248: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:249: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:250: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:251: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:254: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:255: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:256: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:259: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:260: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:261: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:262: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:265: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:266: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:267: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:268: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:271: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:274: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:277: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:278: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:281: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:282: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:283: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:284: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:285: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:286: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:289: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:290: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:291: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:294: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:297: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:298: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:299: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:300: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:301: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:302: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:303: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:304: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:307: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:310: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:311: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:312: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:315: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:316: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:317: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:318: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:319: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:320: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:323: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:324: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:325: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:326: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:327: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:328: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:329: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:330: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:333: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:334: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:340: error: dereferenc=
ing pointer to incomplete type
/home/administer/net-next-2.6/drivers/net/znet.c:345: error: invalid ap=
plication of =91sizeof=92 to incomplete type =91struct i82593_conf_bloc=
k=92
/home/administer/net-next-2.6/drivers/net/znet.c:346: error: invalid ap=
plication of =91sizeof=92 to incomplete type =91struct i82593_conf_bloc=
k=92
/home/administer/net-next-2.6/drivers/net/znet.c:346: error: invalid ap=
plication of =91sizeof=92 to incomplete type =91struct i82593_conf_bloc=
k=92
/home/administer/net-next-2.6/drivers/net/znet.c:346: error: invalid ap=
plication of =91sizeof=92 to incomplete type =91struct i82593_conf_bloc=
k=92
/home/administer/net-next-2.6/drivers/net/znet.c:347: error: invalid ap=
plication of =91sizeof=92 to incomplete type =91struct i82593_conf_bloc=
k=92
/home/administer/net-next-2.6/drivers/net/znet.c:348: error: =91OP0_CON=
=46IGURE=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:348: error: (Each unde=
clared identifier is reported only once
/home/administer/net-next-2.6/drivers/net/znet.c:348: error: for each f=
unction it appears in.)
/home/administer/net-next-2.6/drivers/net/znet.c:348: error: =91CR0_CHN=
L=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c: In function =91znet_t=
x_timeout=92:
/home/administer/net-next-2.6/drivers/net/znet.c:512: error: =91CR0_STA=
TUS_0=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:514: error: =91CR0_STA=
TUS_1=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:516: error: =91CR0_STA=
TUS_2=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:518: error: =91CR0_STA=
TUS_3=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:522: error: =91TX_LOST=
_CRS=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:525: error: =91OP0_RES=
ET=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c: In function =91znet_s=
end_packet=92:
/home/administer/net-next-2.6/drivers/net/znet.c:549: error: =91CR0_STA=
TUS_0=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:583: error: =91OP0_TRA=
NSMIT=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:583: error: =91CR0_CHN=
L=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c: In function =91znet_i=
nterrupt=92:
/home/administer/net-next-2.6/drivers/net/znet.c:612: error: =91CR0_STA=
TUS_0=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:617: error: =91CR0_STA=
TUS_1=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:619: error: =91CR0_STA=
TUS_2=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:621: error: =91CR0_STA=
TUS_3=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:626: error: =91SR0_INT=
ERRUPT=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:631: error: =91SR0_EVE=
NT_MASK=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:631: error: =91SR0_TRA=
NSMIT_DONE=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:632: error: =91SR0_RET=
RANSMIT_DONE=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:633: error: =91SR0_TRA=
NSMIT_NO_CRC_DONE=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:638: error: =91TX_OK=92=
 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:640: error: =91TX_NCOL=
_MASK=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:642: error: =91TX_LOST=
_CTS=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:642: error: =91TX_LOST=
_CRS=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:644: error: =91TX_UND_=
RUN=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:646: error: =91TX_HRT_=
BEAT=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:648: error: =91TX_MAX_=
COL=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:666: error: =91SR0_REC=
EPTION=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:667: error: =91SR0_STO=
P_REG_HIT=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:671: error: =91CR0_INT=
_ACK=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c: In function =91znet_r=
x=92:
/home/administer/net-next-2.6/drivers/net/znet.c:688: error: =91CR0_STA=
TUS_2=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:747: error: =91RX_RCV_=
OK=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:749: error: =91RX_CRC_=
ERR=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:750: error: =91RX_ALG_=
ERR=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:756: error: =91RX_OVRR=
UN=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:758: error: =91RX_SRT_=
=46RM=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c: In function =91znet_c=
lose=92:
/home/administer/net-next-2.6/drivers/net/znet.c:814: error: =91OP0_RES=
ET=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c: In function =91hardwa=
re_init=92:
/home/administer/net-next-2.6/drivers/net/znet.c:859: error: =91OP0_RES=
ET=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:885: error: =91OP0_CON=
=46IGURE=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:885: error: =91CR0_CHN=
L=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:893: error: =91OP0_IA_=
SETUP=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:898: error: =91OP0_RCV=
_ENABLE=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c: In function =91update=
_stop_hit=92:
/home/administer/net-next-2.6/drivers/net/znet.c:904: error: =91OP0_SWI=
T_TO_PORT_1=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:904: error: =91CR0_CHN=
L=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:907: error: =91CR1_STO=
P_REG_UPDATE=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/net/znet.c:909: error: =91OP1_SWI=
T_TO_PORT_0=92 undeclared (first use in this function)
make[3]: *** [drivers/net/znet.o] Error 1
make[3]: *** Waiting for unfinished jobs....
make[2]: *** [drivers/net] Error 2
make[1]: *** [drivers] Error 2
make: *** [sub-make] Error 2
