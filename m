From: "R Harper" <rharper333@hotmail.com>
Subject: RFC 1323
Date: Mon, 04 Apr 2005 18:17:40 +0200
Message-ID: <BAY20-F2375830DACBEC22EDD913C923B0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

I have been taking a look at the timestamp feature in RFC 1323.
My question is how are the TSval and TSecr fields represented in the curr=
ent=20
implementation of linux, e.g. that is the resolution of the timers.
Is the format simply timeval.tv_sec from the time.h or is timeval.tv_usec=
=20
also mixed into the timestamp. (If someone would point to where in the co=
de=20
this is defined)

Another question,  as I understand the RFC, the timestamp are only releva=
nt=20
to the box generating them. Are TCP implementation different in how the=20
TSval data is represented?
Is it possible to make use of the timestamp in an intermediate box, e.g.=20
estimating RTT in a box that a TCP connection passes?

I someone has the time to answer these question, it would be great.
with regards
r.harper

_________________________________________________________________
Undg=E5 pop-ups med MSN Toolbar -  http://toolbar.msn.dk/ hent den gratis=
!
