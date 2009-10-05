From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 0/4][RFC]: coding convention for CCID-struct prefixes
Date: Mon,  5 Oct 2009 12:53:09 +0200
Message-ID: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <ccid_coding_convention>
Cc: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46629 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932611AbZJELGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 07:06:08 -0400
In-Reply-To: <ccid_coding_convention>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaldo, Dave,

this codifies new naming scheme discussed at netconf. Can you please have a
look and indicate whether you are ok with the set?

They are divided into 4 for readability, but can be combined into
one large patch if agreed.

It is all just regexp substitutions:

Patch #1: Introduces the naming scheme on CCID-2:
	    s#hc\(tx\|rx\)->ccid2hc\1_#hc\1->\1_#g;
            s#ccid2hc\(tx\|rx\)_#\1_#g;

Patch #2: Extends the changes of patch#1 to CCID-3.

Patch #3: Removes the second, repetitive redundancy in this scheme:
	    s#hc\(tx\|rx\)->\1_#hc->\1_#g;

Patch #4: Extends patch#3 from CCID-2 to CCID-3.

--
 ccids/ccid2.c |  595 ++++++++++++++++++++++++-------------------------
 ccids/ccid2.h |   46 +--
 ccids/ccid3.c |  692 +++++++++++++++++++++++++++-------------------------------
 ccids/ccid3.h |  120 +++++-----
 probe.c       |   22 -
 5 files changed, 723 insertions(+), 752 deletions(-)

