From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 0/2] inet6: resolve IPV6_TCLASS conversion problems
Date: Sun,  9 Aug 2009 20:12:47 +0200
Message-ID: <1249841569-23706-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <resolve_IPV6_TCLASS>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51966 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752374AbZHISNB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2009 14:13:01 -0400
In-Reply-To: <resolve_IPV6_TCLASS>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are two patches dealing with the IPV6_TCLASS sticky socket option. They
belong together, the second patch is a follow-up and fixes the remainder.

Patch #1: Removes unnecessary conversions (tclass being u8)
          This is a resent, an OK was given in the reply of 
          http://marc.info/?l=linux-netdev&m=124820628409987&w=2
Patch #2: Solves the remaining problem of passing the socket option,
          fixing a bug (-1 became a non-default traffic class of 0xff).
