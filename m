From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 0/3] dccp: several sequence-number validation fixes
Date: Fri,  7 Jan 2011 12:35:27 +0100
Message-ID: <1294400130-5604-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <0110107112837.GA5315@gerrit.erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:57436 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751400Ab1AGLfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 06:35:37 -0500
In-Reply-To: <0110107112837.GA5315@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please find attached 3 bug fixes which recently came up on dccp@vger.

 Patch #1: fixes a bug which wrongly classified sequence-invalid packets. 
 Patch #2: fixes a bug in updating the Greatest Sequence number Received (GSR).
 Patch #3: fixes an inconsistency in setting the sequence window on 32/64 bit.

I have also placed this in into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

---
 Documentation/networking/dccp.txt |    1 +
 net/dccp/dccp.h                   |    3 ++-
 net/dccp/input.c                  |    2 +-
 net/dccp/sysctl.c                 |    4 +++-
 4 files changed, 7 insertions(+), 3 deletions(-)
