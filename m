From: =?iso-8859-1?q?an7?= <an3h0ny@yahoo.fr>
Subject: Van's trick
Date: Thu, 30 Oct 2003 10:48:13 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031030094813.23865.qmail@web11104.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hello ! ;)

> To _combine_ checksumming and copy to user. User
> memory space
> is accessible only from process context, moreover,
> exactly from context
> where read() is made.

ok. so packets are put on a device interrupt directly
on the socket receive queue (there is the problem to
know which socket receive queue choose),we do checksum
and copying to the user buffer. This can be done
simultaneously because we can access user space memory
as we are in process context (read() one). the
prequeue simply is an intermediate queue before
effectively copying data to the user buffer.
(ucopy.prequeue)

That solutions improves performance (latency) but
breaks TCP IP layering. That is to say, i suppose that
while copying to the user buffer, IP and TCP tests are
done (not only checksumming,referred in van's post as
TCP processing),as the packet comes directly from the
device receive queue..

that's interesting.


___________________________________________________________
Do You Yahoo!? -- Une adresse @yahoo.fr gratuite et en fran=E7ais !
Yahoo! Mail : http://fr.mail.yahoo.com
