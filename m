From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 0/4] inet6: minor cleanups
Date: Sun, 19 Jul 2009 20:23:35 +0200
Message-ID: <1248027819-23959-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <inet6_minor_cleanups>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54863 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750729AbZGSSf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 14:35:28 -0400
In-Reply-To: <inet6_minor_cleanups>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a small set of minor-cleanup patches, found while
studying the tclass code.

Patch #1: Unifies return convention of datagram_send_ctl().
Patch #2: Consolidates cmsg code for Traffic Class / Hop Limit.
Patch #3: Simplifies assignments from u8 to int (no conversion).
Patch #4: Finds that RT_TOS() redefines IPTOS_TOS().
