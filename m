From: "rahul hari" <rahulhsaxena@hotmail.com>
Subject: Re: [Linux Diffserv] GRED queueing discipline and the file sch_gred.c
Date: Mon, 06 Jun 2005 16:08:56 +0530
Message-ID: <BAY24-F263AE581155F279A048AE6C5FB0@phx.gbl>
References: <20050605221106.GB15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: diffserv-general@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050605221106.GB15391@postel.suug.ch>
To: tgraf@suug.ch
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dear Thomas,
Thanks for the reply. Actually in my experiment, I am implementing 2 queu=
es,=20
in one of the queues, I use the prio scheme of tc and in another I define=
 3=20
virtual queues, out of which I want to provide absolute priority to one o=
f=20
the queue over the others (ie, if there is any packet in this queue, it=20
should be dispatched immediately regardless of whatever happens to the ot=
her=20
two virtual queues).
For the other two virtual queues, I want to apply individual REDs (with=20
different parameters but the average queue length should be equal to the=20
total qave of these two virtual queues) on each but the dequeuing priorit=
y=20
should be equal (the dequeuing takes place alternately).
Can the current implementations somehow help me with this , or I would ha=
ve=20
to design this from scratch.

Regards,
Rahul

-------
"The fear you let build up in your mind is worse than the situation that=20
actually exists"
taken from "who moved my cheese"
-------------------------------------------------------------------------=
----
Rahul Hari
Senior Undergraduate Student,
Department of CSE,
ITBHU,
Varanasi.
Ph: +91-9845347020
-------------------------------------------------------------------------=
----

_________________________________________________________________
Don=92t just search. Find. Check out the new MSN Search!=20
http://search.msn.click-url.com/go/onm00200636ave/direct/01/
