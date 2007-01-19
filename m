From: Daniele Lacamera <netdev@danielinux.net>
Subject: [ANNOUNCE] FYI: MultiTCP for linux-2.6.19
Date: Fri, 19 Jan 2007 13:15:06 +0100
Message-ID: <1169208906.2266.44.camel@inspiron>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from danielinux.vm.bytemark.co.uk ([80.68.95.85]:1618 "EHLO
	mail.danielinux.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965099AbXASMiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 07:38:01 -0500
To: "Xiaoliang (David) Wei" <davidwei79@gmail.com>,
	Giovanni Pau <gpau@cs.ucla.edu>,
	Carlo Caini <ccaini@deis.unibo.it>,
	Rosario Firrincieli <rfirrincieli@arces.unibo.it>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MultiTCP[1] is (yet another) Linux TCP patch intended for
researchers/developers, which can report TCP events in the kernel logs
in order to watch TCP internal variables.

Furthermore, it includes TCP Pacing and Hoe's initial ssthresh
estimation[2]. Their use in satellite links is strongly recommended by
the TCP-Hybla authors in order to mitigate congestion episodes and limit
the initial cwnd overshoot phenomenon respectively.

A new version for linux-2.6.19 has been released at
http://www.sf.net/projects/multitcp/

Hybla's authors future goal would be to produce official patches for
both Pacing and initial ssthresh estimation, by freeing the latter one
implementation from the TCP kernel logs engine and getting the current
tcp_sock structure slimmer.

Meanwhile, we will appreciate if the comparative tests made on Linux
congestion control will include the two algorithms described above when
using TCP-Hybla.

[1]
C. Caini, R. Firrincieli and D. Lacamera, "A Linux Based Multi TCP
Implementation for Experimental Evaluation of TCP Enhancements", SPECTS
2005, Philadelphia, July 2005.

C. Caini, R. Firrincieli, D. Lacamera, "An emulation approach for the
evaluation of enhanced transport protocols performance in satellite
networks", IEEE Globecom 2006 - Satellite and Space Communications, 27
November-1 December 2006, San Francisco, CA, USA.

[2]
J. C. Hoe, "Improving the Start-up Behavior of a Congestion Control
Scheme for TCP", ACM SIGCOMM 1996, pp. 270-280


Regards,

-- 
Daniele Lacamera

