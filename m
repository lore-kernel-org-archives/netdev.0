From: Parag Nemade <cranium2003@yahoo.com>
Subject: adding own 8 byte header to ip packet
Date: Wed, 21 Apr 2004 01:01:19 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421080119.10446.qmail@web41412.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hello,
 Actually i added my own 8 byte header using skb_push
function in front of transport header in=20
ip_build_and_send_pkt function in ip_output.c file
before skb_push for IP header. same thing i did in
ip_rcv function in ip_input.c to strip off headers.
but when i boot that image and ping the effects in
ping packet will not reflect and after some time i got
kernel BUG at slab 1130!
      Is am i missimg some other modifications.
regards,
Parag


=09
	=09
__________________________________
Do you Yahoo!?
Yahoo! Photos: High-quality 4x6 digital prints for 25=A2
http://photos.yahoo.com/ph/print_splash
