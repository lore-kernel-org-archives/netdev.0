From: =?iso-8859-1?q?an7?= <an3h0ny@yahoo.fr>
Subject: tcp_recvmsg()
Date: Fri, 24 Oct 2003 13:07:34 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031024110734.66548.qmail@web11108.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi here,

I need a confirmation, please :

tcp_recvmsg() is called to retrieve messages from the
socket receive queue, isn't it ? It is used when
userland applications use the recv() call,from BSD
socket API=20

as i said in a post before, i didn't understand a syn
check that was in this function.

Dave Miller told me the check was just here if one
day, the stack will allow data reception with a
syn/ack segment, with data attached (it is technically
possible).

When the established state is reached, the
syn/ack+data segment will be on the socket receive
queue, and so, we have to account for the syn sequence
number, as this sequence number doesn't correspond to
any real data byte.

So i need to effectively confirm that the
tcp_recvmsg() retrieves messages from the socket
receive queue, and which function is responsible for
putting packets in queue (i think it is tcp_data_queue
?)

Thanks

___________________________________________________________
Do You Yahoo!? -- Une adresse @yahoo.fr gratuite et en fran=E7ais !
Yahoo! Mail : http://fr.mail.yahoo.com
