From: Russell King <rmk@arm.linux.org.uk>
Subject: Fwd: tcp checksumming
Date: Tue, 4 Nov 2003 14:28:39 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031104142839.C2207@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Not my problem.

Please ensure that replies are directed at the appropriate address
(ie not me.)

Thanks.


----- Forwarded message from an7 <an3h0ny@yahoo.fr> -----
Date: Tue, 4 Nov 2003 15:17:59 +0100 (CET)
From: an7 <an3h0ny@yahoo.fr>
Subject: tcp checksumming=20

Hello, i am sorry russel, but i asked many times on
netdev without having the answer, i tried to
understand by myself during two weeks..please help me

In tcp_rcv_established(), when you are in fast path,
you use checksum and copy (the first function in the
chain is tcp_copy_to_iovec) to finally delivering data
to the user.

I browse datagram.c,checksum.h,skbuff.c,tcp_input.c
and only sees (mainly by following function calls in
datagram.c) checksum calculation, by a lot of calls to
csum_fold() and csum_partial(), and copy to iovec, but
i have never seen the checksum _verification_.

I learn that skb->csum is (when you have not CHECKSUM
UNECESSARY defined in the case of a device computing
the checksum by itself) the checksum on running
data.But it is used in all functions,and get replaced
by a function result. I don't see where it is used as
a comparison

My question is pretty simple : where in the code, is
the tcp checksum verified (compared to the computed
one). My first impression was that it was done in the
*copy_and_csum* functions, but i only see checksum
computation.

That is to say, it is like a side effect of keeping
data in a buffer with a bad checksum.(maybe it is
removed after ? i don't think so)

___________________________________________________________
Do You Yahoo!? -- Une adresse @yahoo.fr gratuite et en fran=E7ais !
Yahoo! Mail : http://fr.mail.yahoo.com

----- End forwarded message -----

--=20
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
