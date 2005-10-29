From: Fernando Gont <fernando@gont.com.ar>
Subject: ICMP attacks & PMTUD mechanism
Date: Sat, 29 Oct 2005 05:48:47 -0300
Message-ID: <6.2.0.14.0.20051029054837.04018090@pop.frh.utn.edu.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Folks,

A new revision of my internet-draft on "ICMP attacks against TCP" has been 
published. The draft is available at 
http://www.gont.com.ar/drafts/icmp-attacks-against-tcp.html , and at the 
IETF internet-draft public repository: 
http://www.ietf.org/internet-drafts/draft-gont-tcpm-icmp-attacks-05.txt

Linux does not yet implement the PMTUD attack-specific counter-measure, 
which is a very important one.

There are already two implementations of the PMTUD attack-specific 
counter-measure (which mitigates the possible attack even if large TCP 
windows are in use). OpenBSD implemented the first one, and NetBSD ported 
it to their OS. Both OSes now ship with the counter-measure enabled by default.

I personally built and tested OpenBSD's implementation, together with other 
developers. Even if you can guess a valid TCP sequence number (as you can 
expect if large windows are in use), you're still immune to the PMTUD attack.

The current version of the draft (-05) includes a pseudo-code version of 
the counter-measure, which makes its implementation very straight-forward.

You can find audit tools at my web site 
(http://www.gont.com.ar/tools/icmp-attacks/index.html), so that, if you 
decide to implement the counter-measure for Linux, you can test it.

P.S.: The latest version of my draft also discusses some corner cases of 
the PMTUD attack you may find it worthwhile reading, to check Linux 
behavior on this issue (see Section 7.1). (Talk about freezing 
IPSec-secured connections, for example)

Kindest regards,

--
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@acm.org
