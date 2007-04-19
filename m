From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 0/0] Re-try changes for PMTUDISC_PROBE
Date: Wed, 18 Apr 2007 21:07:10 -0400
Message-ID: <4626C0BE.2050205@psc.edu>
References: <11746948063923-git-send-email-jheffner@psc.edu> <4619FBEE.70103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:54348 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030977AbXDSBHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 21:07:20 -0400
In-Reply-To: <4619FBEE.70103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This backs out the the transport layer MTU checks that don't work.  As a 
consequence, I had to back out the PMTUDISC_PROBE patch as well.  These 
patches should fix the problem with ipv6 that the transport layer change 
tried to address, and re-implement PMTUDISC_PROBE.  I think this 
approach is nicer than the last one, since it doesn't require a bit in 
struct sk_buff.

Thanks,
   -John
