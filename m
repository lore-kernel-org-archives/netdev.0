From: =?iso-8859-1?q?an7?= <an3h0ny@yahoo.fr>
Subject: tcp_recv_skb, tcp_read_sock and tcp_recvmsg useless check ?
Date: Thu, 23 Oct 2003 13:02:47 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031023110247.55464.qmail@web11102.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,=20

If we have a look at tcp_recv_skb, and
tcp_read_sock(),

we notice that there is a SYN check, and if the flag
is on, we do offset-- (sequence number not
corresponding to real data byte).=20

This Syn check is useless, as the function cannot be
called at the beginning of a connection (since we have
not copied_seq filled with the last sequence number of
the last packet passed to the upper layer)
=20
What do you think of that ?




___________________________________________________________
Do You Yahoo!? -- Une adresse @yahoo.fr gratuite et en fran=E7ais !
Yahoo! Mail : http://fr.mail.yahoo.com
