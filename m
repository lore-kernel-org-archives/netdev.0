From: Parag Nemade <cranium2003@yahoo.com>
Subject: how data travels across tcp stack?
Date: Thu, 22 Apr 2004 00:27:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040422072707.15370.qmail@web41411.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: net dev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
1)which function in kernel source tree actually takes
data from application to be send it as a packet?
2)when one layer gives control to next layer i.e. from
transport to IP layer is it neccessary for transport
layer to occur interrupt to give control to next
layer?
3)i am not getting line in ip_fragment function
if ((skb2 =3D
alloc_skb(len+hlen+dev->hard_header_len+15,GFP_ATOMIC))
=3D=3D NULL) in ip_output.c. i want to know what is the
mean
ing for 15 value when skbuff is allocated for new
fragment?
regards,
parag.


=09
	=09
__________________________________
Do you Yahoo!?
Yahoo! Photos: High-quality 4x6 digital prints for 25=A2
http://photos.yahoo.com/ph/print_splash
