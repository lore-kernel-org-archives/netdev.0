From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [Patch 0/2] dccp: Fix issues in setting the MPS
Date: Sat, 28 Feb 2009 09:38:27 +0100
Message-ID: <1235810309-10256-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_setting_MPS_based_on_negotiated_features>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33802 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751708AbZB1IjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2009 03:39:04 -0500
In-Reply-To: <dccp_setting_MPS_based_on_negotiated_features>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

can you please consider this update, changes are summarized below and
patches have been in the test tree for a long while - it builds upon the
feature-negotiation infrastructure.

Gerrit


Patch summary:
--------------
The set fixes issues in setting the Maximum Packet Size (aka MSS/MTU).

Making efficient use of available packet space is even more important in
DCCP than in UDP, since fragmentation is discouraged as per RFC 4340, 14.


Patch #1: Computes MPS for common data-packet options and dynamically 
	  adapts this value depending on negotiated features.
Patch #2: Fixes a problem that arises for the MPS due to the overlap of
	  half-established and established connection phases in DCCP.


Patch stats:
------------
 ackvec.h |    3 +++
 dccp.h   |    5 ++++-
 output.c |   37 ++++++++++++++++++++++++++++---------
 3 files changed, 35 insertions(+), 10 deletions(-)


The set is also available for viewing online, at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=6a58dc066df272c22c5caf07c486f8538307bb68
