From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [RFC 0/5] generic rx recycling
Date: Wed,  5 May 2010 16:47:45 +0200
Message-ID: <1273070870-7821-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:51290 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932329Ab0EEOr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 10:47:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series merges the rx recycling code trying to come up with generic
code. Recycling skbs from the tx path for incomming rx skips the memory
allocater and improves latency during memory pressure.
This is now used by just by just four drivers in the tree which were doing
this on their own.

Sebastian

