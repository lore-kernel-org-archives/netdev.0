From: "Nivedita Singhvi" <nivedita@us.ibm.com>
Subject: Re: [possibly O-T] ip-sysctl calls and a few questions.
Date: Fri, 3 May 2002 09:31:46 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <OFCE961DC9.D1FD208D-ON88256BAE.0058E727@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Oskar Andreasson" <blueflux@koffein.net>
List-Id: netdev.vger.kernel.org



> First off, I'm working on a larger document which contains
> a reference to all ipv4 sysctl calls available in linux.
> The reference part of the document is heavily based upon
> linux/Documentation/networking/ip-sysctl.txt document written
> by various writers, as it looks now. The main problem is that
> I have quite a problem understanding the behaviours of some
> variables/sysctl calls, and what they do.

Thats good! I've just updated the TCP man page with the TCP
sysctls. Will send it out shortly, that will cover some of your
questions below, but I thought I'd send a brief response now:

> I will (try to :-)) briefly sum up all questions I have at
> this moment below:

> tcp_max_syn_backlog - I haven't looked in the source code for
> this one myself, but the default values listed in the
> ip-sysctl.txt document are faulty in comparison to the default
> values I get on my own systems. Are these calculated at boot
> time, or is the document simply old?

The default val is 256 - but is adjusted at boot time depending
on memory available in the system (1024 if > 128MB).

> tcp_fack - Does this variable turn on Fast Acknowledgement,
> and if so, in which RFC is this documented? RFC 2018, 2883
> or some other?

Forward Acknowledgement. Not an RFC - but there is a paper,
Alexey might have to confirm that..I'll add a ptr to it..

> tcp_reordering - What does it mean? How does it work?
> Is there any RFC documenting this and what the default behaviour
> should be?

Again, no RFC. Its a mechanism to detect the reordering of packets
and avoid unnecessary retransmission and back off..

> tcp_adv_win_scale - I can say nothing but "hmmm" about the
> explanation in the ip-sysctl.txt document, and I understand
> pretty much nothing from what I've read in the source, though
> I haven't even tried very much so far. What do the different
> equations do as specified in ip-sysctl.txt? What do the variables
> used in them mean? Perhaps I'm just dumb or something :-).

It determines how to share the buffer space between the application
and the kernel - if the default is 2, the buffering overhead (system
space is one fourth of the buffer...

> Those are the questions I have for now.. Sorry for the massive amount
> of questions, but I have collected them for a week or so :-).
> I really really hope this is not offtopic for this list and that noone
> will get too annoyed over the questions and that someone is able to
> reply to them.


thanks,
Nivedita
