From: "Paul Albrecht" <palbrecht@qwest.net>
Subject: Re: question about linux tcp request queue handling
Date: Mon, 7 Jul 2003 16:30:47 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <001401c344df$ccbc63c0$6801a8c0@oemcomputer>
References: <3F08858E.8000907@us.ibm.com> <001a01c3441c$6fe111a0$6801a8c0@oemcomputer> <3F08B7E2.7040208@us.ibm.com> <000d01c3444f$e6439600$6801a8c0@oemcomputer> <3F090A4F.10004@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, "netdev" <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Nivedita Singhvi" <niv@us.ibm.com>
List-Id: netdev.vger.kernel.org

Nivedita Singhvi writes:

>
> Again, youre limiting the number of connnection requests
> that are allowed to wait in the *accept* queue, where
> we move to once we're ESTABLISHED.  You arent limiting
> a request sitting in the SYN queue.
>

This statement is inconsistent with the description of this scenario in
Steven's TCP/IP Illustrated.  Specifically, continuing the handshake in the
TCP layer, i.e., sending a syn/ack and moving to the syn_recd state, is
incorrect if the limit of the server's socket backlog would be exceeded.
How do you account for this discrepancy between linux and other
berkeley-derived implementations?
