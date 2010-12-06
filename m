From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 0/2] dccp: Policy-based packet dequeueing interface
Date: Mon,  6 Dec 2010 08:44:02 +0100
Message-ID: <1291621444-5927-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_net_next_2_6__packet_dequeueing_interface>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46508 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751222Ab0LFHoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 02:44:16 -0500
In-Reply-To: <dccp_net_next_2_6__packet_dequeueing_interface>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please find attached a self-contained 2-patch set by Tomasz which adds an API
to influence DCCP packet dequeueing. It evolved from discussions in 2008,
adding and adds basic building blocks for sending congestion controlled
multimedia packets that have a priority or a deadline attached to them.

Occasionally people still make new suggestions for such an API, apparently
overlooking the excellent work Tomasz has done and which has been in the
test tree for two years.

 Patch #1: introduces the new policy-based packet dequeueing infrastructure.
 Patch #2: adds parameter (sanity) checking of cmsg qpolicy parameters.

I have also placed this in into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

The set is fully bisectable.
---
 Documentation/networking/dccp.txt |   20 ++++++
 include/linux/dccp.h              |   21 ++++++
 net/dccp/Makefile                 |    4 +-
 net/dccp/dccp.h                   |   13 ++++
 net/dccp/output.c                 |    7 +-
 net/dccp/proto.c                  |   71 ++++++++++++++++++-
 net/dccp/qpolicy.c                |  137 +++++++++++++++++++++++++++++++++++++
 7 files changed, 264 insertions(+), 9 deletions(-)
