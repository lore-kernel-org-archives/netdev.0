From: =?iso-8859-1?q?francois=20donzet?= <fdonzet@yahoo.fr>
Subject: checksum offloading
Date: Mon, 10 Nov 2003 12:29:15 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110112915.3483.qmail@web25201.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

i have a little question :=20

When tcp checksum offloading is enabled, the chip
computes a sum on all words of the packet contents and
stores the result in skb->csum, setting skb->ip_summed
to CHECKSUM_HW. (see for example, e100_main.c)

Then, when packet reaches tcp layer, via
tcp_checksum_init(), tcp checksum is verified (using
together skb->csum and the pseudo header checksum).

How does TCP deal with skb->csum, as it doesn't cover
only the tcpheader+data (but ipheader+tcpheader+data)

Thanks.



___________________________________________________________
Do You Yahoo!? -- Une adresse @yahoo.fr gratuite et en fran=E7ais !
Yahoo! Mail : http://fr.mail.yahoo.com
