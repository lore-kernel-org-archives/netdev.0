From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 0/2] sctp: Two small bugfixes.
Date: Fri, 13 Jun 2008 09:49:07 -0400
Message-ID: <1213364949-9997-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:45438 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbYFMNtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 09:49:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

The following are two small bug fixes that have been day-one bugs.

The first one takes care of the failure cases when creating /proc
entries.

The second, in addition to being the right thing to do, fixes
a problem with fast retransmit where the very first packet association
sends is never fast-rtxed.

Thanks
-vlad
