From: Fernando Gont <fernando@gont.com.ar>
Subject: TCP's reaction to soft errors
Date: Wed, 15 Sep 2004 11:44:14 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4.3.2.7.2.20040915112853.00cf9980@mail.daleclick.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Folks,

I'm the author of an IETF Internet Draft that discusses a problem arising 
from the current TCP's reaction to soft errors. The problem has to do with 
long delays in connection establishment attempts that may arise in a number 
of scenarios.
The draft proposes to change TCP's reaction to soft errors so that 
connections that are in the SYN-SENT or SYN-RECEIVED states are aborted 
upon receipt of an ICMP error message that indicates a soft error.

The draft can be found at: 
http://www.ietf.org/internet-drafts/draft-gont-tcpm-tcp-soft-errors-00.txt .

I've also put online a "Discussion List" I had prepared for the last IETF 
meeting, which has a somewhat expanded explanation of the rationale behind 
the proposed fix. This document can be found at: 
http://www.gont.com.ar/drafts/TCP-Soft-Errors-Discussion-List.doc .

I'd appreciate any comments on the draft. Thus, I'd be able to address your 
comments in the next revision of the draft, and will also sum-up your 
feedback and post it to the relevant IETF mailing list (that of the TCPM WG 
mailing-list).

BTW, I've set up a page at 
http://www.gont.com.ar/drafts/tcp-soft-errors.html so that you have all the 
documents available from a single place.

--
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@acm.org
