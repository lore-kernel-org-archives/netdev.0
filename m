From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 0/2] dccp: fix slow slow-start by symmetric Syn-RTT
Date: Tue, 22 Jun 2010 13:14:33 +0200
Message-ID: <1277205275-5862-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <ccid3_4_tfrc_slow_slow_start_issue>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:64346 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752163Ab0FVL0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 07:26:37 -0400
In-Reply-To: <ccid3_4_tfrc_slow_slow_start_issue>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changeset fixes slow startup behaviour for DCCP streaming via
CCID-3/4 when a listening server needs to start streaming.

Patch #1: removes an unused 'sk' argument from several functions,
          it is used by patch #2;

Patch #2: fixes the sluggish slow-start problem by taking an RTT
          sample from the initial handshake also for listeing servers.
