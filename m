From: Andi Kleen <ak@suse.de>
Subject: Re: question about linux tcp request queue handling
Date: 07 Jul 2003 23:48:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <p73fzliqa91.fsf@oldwotan.suse.de>
References: <3F08858E.8000907@us.ibm.com.suse.lists.linux.kernel>
	<001a01c3441c$6fe111a0$6801a8c0@oemcomputer.suse.lists.linux.kernel>
	<3F08B7E2.7040208@us.ibm.com.suse.lists.linux.kernel>
	<000d01c3444f$e6439600$6801a8c0@oemcomputer.suse.lists.linux.kernel>
	<3F090A4F.10004@us.ibm.com.suse.lists.linux.kernel>
	<001401c344df$ccbc63c0$6801a8c0@oemcomputer.suse.lists.linux.kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: niv@us.ibm.com, linux-kernel@vger.kernel.org,
   "netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Paul Albrecht" <palbrecht@qwest.net>
In-Reply-To: <001401c344df$ccbc63c0$6801a8c0@oemcomputer.suse.lists.linux.kernel>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Paul Albrecht" <palbrecht@qwest.net> writes:

> This statement is inconsistent with the description of this scenario in
> Steven's TCP/IP Illustrated.  Specifically, continuing the handshake in the
> TCP layer, i.e., sending a syn/ack and moving to the syn_recd state, is
> incorrect if the limit of the server's socket backlog would be exceeded.
> How do you account for this discrepancy between linux and other
> berkeley-derived implementations?

The 4.4BSD-Lite code described in Stevens is long outdated. All modern
BSDs (and probably most other Unixes too) do it in a similar way to what 
Nivedita described. The keywords are "syn flood attack" and "DoS". 

-Andi
